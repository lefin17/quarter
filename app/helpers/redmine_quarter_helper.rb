module RedmineQuarterHelper
# require 'cgi'
# copy from report_helper.rb
# 2015-12-09
# 2015-12-10 added aggregate_filter

  def aggregate(data, criteria)
    a = 0
    data.each { |row|
      match = 1
      criteria.each { |k, v|
        match = 0 unless (row[k].to_s == v.to_s) || (k == :closed &&  (v == 0 ? ['f', false] : ['t', true]).include?(row[k]))
      } unless criteria.nil?
      a = a + row[:total].to_i if match == 1
    } unless data.nil?
    a
  end
  
def url_encode(str)
str = ERB::Util.url_encode(str)
str
end

  def aggregate_link(data, criteria, *args)
    a = aggregate data, criteria
    a > 0 ? link_to(h(a), *args) : '-'
  end

  def aggregate_path(project, field, row, options={})
    parameters = {:set_filter => 1, field => row.id }.merge(options)
    # parameters = {:set_filter => 1, :subproject_id => '!*', field => row.id}.merge(options)
    project_issues_path(row.is_a?(Project) ? row : project, parameters)
  end

  def aggregate_filter(project, data, options = {})
# нужно выципить по входным условиям нужную строку, из нее нужные данные и настройки фильтра для списка задач 
 # logger.info("options")
 # logger.info(options)
    d = {}
    data.each{|row|
        match = 1
        options.each { |k, v|
            match = 0 unless (row[k].to_s == v.to_s)
    	    } unless options.nil?
    	   row.each{|k, v| d[k] = v} unless match == 0
	} unless data.nil?
	
conditions = d[:options] unless d.nil?
	
#    logger.info(project)
    link = "/projects/" + project.identifier + "/issues?set_filter=1";
    conditions.each{ |option|
#    logger.info(option)
       link << "&f[]=" + option[:key]
       link << "&op[" + option[:key] + "]="+ url_encode(option[:option]) unless option[:option].nil?
       link << "&v[" + option[:key] + "][]=" + url_encode(option[:value].to_s) unless option[:value].nil?
       link << "&v[" + option[:key] + "][]=" + option[:first] unless option[:first].nil?
       link << "&v[" + option[:key] + "][]=" + option[:last] unless option[:last].nil?
     } unless conditions.nil?
    number = aggregate(data, options)
    if number > 0 
    link_s = '<a href="'+link+'">'+number.to_s+'</a>'
    else 
    link_s = "-"
    end
    link_s
  end
  
end
