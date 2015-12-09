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
       {:id => 2, :name => I18n.t("quarter_7_days"), :period => t..t - 7.day},	  
       {:id => 3, :name => t.strftime("%B %Y"), :period => t.all_month },
       {:id => 4, :name => t2.strftime("%B %Y"), :period =>  t2.all_month }
    ]
    @staff = Principal.member_of(@project).sort	
    @issues = Issue.on_active_project	
    end
    
def find_issues(period, person)

    assigned = @issues.where(issues: { due_date: period, assigned_to_id: person }).count 
    closed = @issues.where(issues: { closed_on: period, assigned_to_id: person }).count
    canceled = @issues.where(issues: { closed_on: period, assigned_to_id: person, status_id: 6 }).count
#    logger.info(period.methods)
#    logger.info(period.first)
    opened = @issues.where("status_id<?", 5).count
    ends = @issues.where(issues: {due_date: period}).where(issues: {assigned_to_id: person}).where("status_id<? or closed_on > ?", 5, period.first).count
    
    unless ends == 0  
	kpi = closed/ends
	else 
	kpi = 0
    end
    is = []
    is <<  { :name => "assigned",
		:assigned_to_id => person,
		:total => assigned 
		}
		
    is <<  { :name => "closed",
	        :assigned_to_id => person, 
	        :closed => 1,
	        :total => closed
	        }
	        
    is << { :name => "canceled",
		:closed => 1,
		:assigned_to_id => person,
		:total => canceled 
		} 
		
    is <<  { :name => "opened",
		:closed => 0,
		:assigned_to_id => person,
		:total => opened
	        }
	        	
    is <<  { :name => "ends",
		:assigned_to_id => person,
		:total => ends
		}		
    is <<  { :name => "kpi",
		:assigned_to_id => person, 
		:total => kpi
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
    logger.info(res)
  end
  
def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id])
  end
end
