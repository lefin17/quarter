module RedmineQuarterHelper

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
  /* нужно выципить по входным условиям нужную строку, из нее нужные данные и настройки фильтра для списка задач */
    data.each{|d|
        n = 0 
	n = aggregate(d, options)
	row = d if n>0
	} unless data.nil?
	
    options = row[:options] unless row.nil?
	
    link = "/" + project.to_s + "/?set_filter=1";
    
    for option in options
       link << "&f[]=" + option[:key]
       link << "&op[" + option[:key] + "]="+ option[:option] unless option[:option].nil?
       link << "&v[" + option[:key] + "][]=" + option[:value] unless option[:value].nil?
       link << "&v[" + option[:key] + "][]=" + option[:first] unless option[:first].nil?
       link << "&v[" + option[:key] + "][]=" + option[:last] unless option[:last].nil?
     end unless options.nil?
     link_s = '<a href="'+link+'">'+aggregate(data, options)+'</a>'
     link_s
  end
  
end
