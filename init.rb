Redmine::Plugin.register :redmine_quarter do
  name 'Redmine Quarter plugin'
  author 'Alexey Poliansky'
  description 'Check workflow in current project for few periods'
  version '0.0.3'
  url 'https://github.com/lefin17/quarter'
  author_url 'https://github.com/lefin17'
 
 
 # permission :redmine_quarter, { :redmine_quarter => [:index] }, :public => true 
  project_module :quarter do
       permission :view_quarter, :quarter => :index
       end
  menu :project_menu, :quarter, { :controller => 'quarter', :action => 'index' }, :caption => 'KPI', :after => :news, :param => :project_id
end
