class ProjectsWorkWeekSerializer < ActiveModel::Serializer
  attributes :aid, :ip, :ia, :wwid, :eh, :ah, :cw, :y, :bow
  
  def bow
    object.beginning_of_week
  end
  
  def y
    object.year
  end
  
  def cw
    object.cweek
  end
  
  def ah
    object.actual_hours
  end
  
  def eh
    object.estimated_hours
  end
  
  def wwid
    object.work_week_id
  end
  
  def ia
    object.is_archived
  end
  
  def ip
    object.is_proposed
  end
  
  def aid
    object.assignment_id
  end
end
