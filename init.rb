Redmine::Plugin.register :redmine_quarter do
  name 'Redmine Quarter plugin'
  author 'Alexey Poliansky'
  description 'Check workflow in current project of last three months'
  version '0.0.1'
  url 'http://support.gretta.ru/plugin_quarter'
  author_url 'http://support.gretta.ru/poliansky'
 
 
 # permission :redmine_quarter, { :redmine_quarter => [:index] }, :public => true 
  project_module :quarter do
       permission :view_quarter, :quarter => :index
       end
  menu :project_menu, :quarter, { :controller => 'quarter', :action => 'index' }, :caption => 'KPI', :after => :news, :param => :project_id
end
