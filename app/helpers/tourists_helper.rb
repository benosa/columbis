# -*- encoding : utf-8 -*-
module TouristsHelper
  def tourist_mustache_data(tourist)
    {
      :full_name => tourist.full_name,
      :passport_series => tourist.passport_series,
      :passport_number => tourist.passport_number,
      :passport_valid_until => tourist.passport_valid_until,
      :phone_number => tourist.phone_number,
      :address => tourist.address,
      :date_of_birth => tourist.date_of_birth,
      :show_link => link_to(t('show'), tourist),
      :edit_link => link_to(t('edit'), edit_tourist_path(tourist)),
      :destroy_link => link_to(t('destroy'), tourist, :method => :delete, :confirm => t('are_you_sure')),
    }
  end

  def tourist_state_filter_options
    res =
      [
        [I18n.t('potential_states.all'), 'all'],
        [I18n.t('potential_states.in_work'), 'in_work']
      ]

    if can?(:extended_potential_clients, :user)
      res = res + Tourist::EXTENDED_POTENTIAL_STATES.map{ |st| [ I18n.t("potential_states.#{st}"), st ] }
    else
      res = res + Tourist::POTENTIAL_STATES.map{ |st| [ I18n.t("potential_states.#{st}"), st ] }
    end

    res
  end

  def show_potential_clients
    params[:potential].present?
  end

  def last_tourist_comments(tourist)
    if cannot?(:extended_potential_clients, :user)
      tourist.actions
    else
      comments = TouristComment.where(tourist_id: tourist.id).last(5)
      title = ""

      for comment in comments
        sub = ""
        sub = "..." if comment.body.length > 100
        title = title +  "\n\n" if title.length > 0
        title = title + "#{comment.user.try(:full_name)}: #{truncate(comment.body, :length => 100)}#{sub}"
      end

      title
    end
  end

  def tourist_comment(tourist)
    if cannot?(:extended_potential_clients, :user)
      tourist.actions
    else
      tourist.tourist_comments.count > 0 ? tourist.tourist_comments.last.body : ""
    end
  end

  # alias_method :orig_tourists_path, :tourists_path
  # def tourists_path(args = nil)
  #   if tourist || show_potential_clients
  #     orig_tourists_path(potential: 1)
  #   else
  #     orig_tourists_path
  #   end
  # end

end
