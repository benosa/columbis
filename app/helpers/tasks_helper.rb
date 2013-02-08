# -*- encoding : utf-8 -*-
module TasksHelper

  def status_filter_options
    [
      [t('task_status.active'), 'active'],
      [t('task_status.all'), 'all']
    ] + Task::STATUS.map{ |st| [ t("task_status.#{st}"), st ] }
  end

  def type_filter_options
    [
      [t('task_type.all'), 'all'],
      [t('task_type.bug'), 'bug'],
      [t('task_type.offer'), 'offer']
    ]
  end
end
