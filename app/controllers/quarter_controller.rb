class QuarterController < ApplicationController
  unloadable
  include Redmine::I18n
  helper RedmineQuarterHelper
 
 before_filter :find_project, :authorize, :only => :index
 require 'date'
  
def prepare
    t = Time.now
    t2 = t - 1.month
    @periods = [
       {:id => 1, :name => I18n.t("quarter_current_week"), :period => t.all_week},
       {:id => 2, :name => I18n.t("quarter_7_days"), :period => t - 7.day..t},	  
       {:id => 3, :name => t.strftime("%B %Y"), :period => t.all_month },
       {:id => 4, :name => t2.strftime("%B %Y"), :period =>  t2.all_month }
    ]
    @staff = Principal.member_of(@project).sort	
    @issues = Issue.on_active_project	
    end

def make_option(key, person, period)
    assigned_id = { :key => "assigned_to_id",
		    :option => "=",
		    :value => person		
		    }
    
    options = []
    options << assigned_id
      case key
      when :closedbefore 
         options << { :key => "status_id",
        	      :option => "c" }
        	      start = period.first - 1.day
         options << { :key => "closed_on",
        	      :option => "<=",
        	      :value => start.strftime("%Y-%m-%d")
        	      }
        options << option_period("due_date", period)
    		    
        
      when :closed # закрытые за период (включая отмененные)
       options  << { :key => "status_id",
		     :option => "c" }
       options << option_period("closed_on", period) 
      
      when :assigned # назначенные задания
       options << option_period("due_date", period)    

      when :endless # без указания даты выполнения
       options << { :key => "due_date",
    		    :option => "!*",
    		    }
       options << option_period("created_on", period)
	when :canceled # отмененные
          options << { :key => "status_id",
		       :option => "=",
		       :value => 6 }
          options << option_period("closed_on", period)
          
	when :opened 
	   options << { :key => "status_id", 
		       :option => "o" }
	   options << option_period("due_date", period)
	options	       
      end
      
    options
    end
def option_period(key, period)
    a = {}
    a[:key] = key
    a[:option] = "><"
    a[:first] = period.first.strftime("%Y-%m-%d")
    a[:last] = period.last.strftime("%Y-%m-%d")
    a 
    end    
    
def find_issues(period, person)
    due_date = "due_date>=? and due_date<=?", period.first.strftime("%Y-%m-%d"), period.last.strftime("%Y-%m-%d")
    closed_on = "closed_on>=? and closed_on<=?", period.first.strftime("%Y-%m-%d"), period.last.strftime("%Y-%m-%d 23:59:00")
    created_on = "issues.created_on>=? and issues.created_on<=?", period.first.strftime("%Y-%m-%d"), period.last.strftime("%Y-%m-%d 23:59:59")
    
    assigned = @issues.where(due_date).where(issues: {assigned_to_id: person }).count 
    closedbefore = @issues.where(issues: { assigned_to_id: person }).where(due_date).where("closed_on<? and closed_on is not null", period.first.strftime("%Y-%m-%d")).count 
    closed = @issues.where(issues: { assigned_to_id: person }).where(closed_on).count
    canceled = @issues.where(issues: { assigned_to_id: person}).where(closed_on).where("status_id = ?", 6).count
    opened = @issues.where(due_date).where(issues: {assigned_to_id: person}).where("status_id<?", 5).count
    endless = @issues.where(issues: {due_date: nil}).where(issues: {assigned_to_id: person}).where(created_on).count
#    ends = @issues.where(due_date).where(issues: {assigned_to_id: person}).where("status_id<? or closed_on > ?", 5, period.first).count
    
    unless (assigned - closedbefore + endless) == 0  
	kpi = (100.0*(closed+canceled))/(assigned - closedbefore + endless)
	else 
	kpi = 0
    end
    is = []
    
    
    is <<  { :name => "assigned",
		:assigned_to_id => person,
		:total => assigned,
		:options => make_option(:assigned, person, period),
    		}
    is << { :name => "endless", 
	    :assigned_to_id => person, 
	    :total => endless,
	    :options => make_option(:endless, person, period),
	    }		
    is <<  { :name => "closed",
	     :assigned_to_id => person, 
	     :closed => 1,
	     :total => closed,
	     :options => make_option(:closed, person, period)
	     }
    is << { :name => "closedbefore",
	    :assigned_to_id => person, 
	    :closed => 1,
	    :total => closedbefore, 
	    :options => make_option(:closedbefore, person, period)
	    }
    is << { :name => "canceled",
	    :closed => 1,
	    :assigned_to_id => person,
	    :total => canceled,
	    :options => make_option(:canceled, person, period),
	    } 
    is <<  { :name => "opened",
             :closed => 0,
	     :assigned_to_id => person,
	     :total => opened,
	     :options =>  make_option(:opened, person, period),
	    }
	        
    is <<  { :name => "kpi",
		:assigned_to_id => person, 
		:total => kpi,
		}
     return is
end
    
def find_period(p)
#    res = {}
     res = []
    @staff.each{|s| find_issues(p[:period], s.id).each{ |i| res << i }}
    return res
end

def index
    res = {}
    prepare 
    @periods.each{ |p| res[p[:id]] = find_period(p)}  
    @res_to_table = res
#    logger.info(res)
  end
  
def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id])
  end
end
