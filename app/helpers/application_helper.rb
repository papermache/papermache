module ApplicationHelper

  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def sortable(column, title = nil)
    title ||= column.titlize

    if title == 'Most Voted'
      direction = 'desc'
      link_to title, params.merge(sort: column, direction: direction)
    elsif title == 'Lease Voted'
      direction = 'asc'
      link_to title, params.merge(sort: column, direction: direction)
    else

      direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
      link_to title, params.merge(sort: column, direction: direction)

    end

  end

end
