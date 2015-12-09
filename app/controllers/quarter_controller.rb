class QuarterController < ApplicationController
  unloadable
  include Redmine::I18n
 
 before_filter :find_project, :authorize, :find_issue_statuses, :only => :index
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
    logger.info(period.methods)
    logger.info(period.first)
    open = @issues.where("status_id<?", 5).count
    ends = @issues.where("status_id<? or closed_on > ?", 5, period.first).where(issues: {assigned_to_id: person}).count
    
    unless ends == 0  
	kpi = closed/ends
	else 
	kpi = 0
    end
    issue = { :assigned => assigned,
    	      :closed => closed,
    	      :canceled => canceled,
              :open => open,
    	      :ends => ends,
    	      :kpi => kpi } 
     return issue
end
    
def find_period(p)
    res = {}
    @staff.each{|s| res[s.id] = find_issues(p[:period], s.id)}
    return res
end

def index
    res = {}
    prepare 
    @periods.each{ |p| res[p[:name]] = find_period(p)}  
    @res_to_table = res
  end
  
def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id])
  end
end
