# -*- encoding : utf-8 -*-
class TouristsController < ApplicationController
  include TouristsHelper
  load_and_authorize_resource

  before_filter :set_last_search, :only => :index

  def index
    if show_potential_clients && ( is_manager? || is_supervisor? )
      by_office = true
    end

    @tourists =
      if search_or_sort?
        options = search_and_sort_options(:with => current_ability.attributes_for(:read, Tourist), :without => {})
        options[:with][:user_id] = params[:user_id].to_i if params[:user_id].present?
        options[:with][:office_id] = current_user.office.id if by_office
        options[:with][:office_id] = params[:office_id].to_i if params[:office_id].present? && !(is_manager? || is_supervisor?)
        if params[:state] == 'in_work'
          options[:without][:state_crc32] = ['reserved'.to_crc32, 'refused'.to_crc32]
        elsif params[:state] != 'all'
          options[:with][:state_crc32] = params[:state].try(:to_crc32)
        end

        checkout_order(options)
        scoped = Tourist.search_and_sort(options).includes(:address, :office, (:user if show_potential_clients))
        scoped = scoped.potentials if show_potential_clients
        scoped = search_paginate(scoped, options)
      else
        scoped = Tourist.send(show_potential_clients ? :potentials : :clients)
        scoped = scoped.accessible_by(current_ability).includes(:address, :office, (:user if show_potential_clients))
        scoped = scoped.where(office_id: current_user.office.id) if by_office
        scoped = scoped.reorder('created_at DESC') if show_potential_clients
        scoped.paginate(:page => params[:page], :per_page => per_page)
      end

    render :partial => 'list' if request.xhr?
  end

  def new
    @tourist.potential = true if show_potential_clients
    check_address(@tourist)
  end

  def create
    @tourist.company = current_company
    @tourist.set_params(tourist_params)
    @tourist.user = current_user
    @tourist.office = current_user.office if !(tourist_params[:office_id].to_i > 0)
    set_images
    if @tourist.save
      if params[:save_and_close]
        redirect_to_tourists(@tourist.potential?, :created)
      else
        redirect_to edit_tourist_url(@tourist), notice: t("tourists.messages.#{@tourist.potential? ? 'client_' : ''}created")
      end
    else
      @tourist.user = nil
      check_address(@tourist)
      render :action => "new"
    end
  end

  def edit
    check_address(@tourist)
    check_office(@tourist)
  end

  def update
    @tourist.company = current_company
    @tourist.set_params(tourist_params)
    @tourist.office = @tourist.user.office if !(tourist_params[:office_id].to_i > 0)
    manager = @tourist.user
    @tourist.user = current_user unless manager
    set_attrs
    if @tourist.update_attributes(tourist_params)
      if params[:save_and_close]
        redirect_to_tourists(@tourist.potential?, :updated)
      else
        redirect_to edit_tourist_url(@tourist), notice: t("tourists.messages.#{@tourist.potential? ? 'client_' : ''}updated")
      end
    else
      @tourist.user = nil unless manager
      check_address(@tourist, params[:potential])
      render :action => "edit"
    end
  end

  def show
    check_office(@tourist)
  end

  def destroy
    @tourist.destroy
    unless request.xhr?
      redirect_to_tourists(@tourist.potential?, :destroyed)
    else
      render :text => ''
    end
  end

  def create_comment
    if can?(:extended_potential_clients, :user)
      body = params[:body].gsub(/\n/, '<br>')
      @comment = TouristComment.new(body: body)
      @comment.user = current_user
      @comment.tourist = @tourist
      @comment.save
      render :json => {
        :id => @comment.id,
        :date => l(@comment.created_at, :format => :long),
        :name => @comment.user.full_name,
        :body => body.html_safe,
        :path => tourist_destroy_comment_path(@tourist, @comment)
      }
    else
      render :json => {
        :fail => 1
      }
    end
  end

  def destroy_comment
    @comment = TouristComment.find(params[:comment_id])
    if @comment.user == current_user && @comment.created_at.day == Date.today.day
      @comment.destroy
      render :json => {
          :id => params[:comment_id]
      }
    end
  end

  private

    def tourist_params
      tourist_params = params[:tourist]
      if cannot?(:extended_potential_clients, :user)
        if !Tourist::POTENTIAL_STATES.include?(tourist_params['state'])
          tourist_params['state'] = 'selection'
        end
        tourist_params.delete('tourist_tasks_attributes')
      end
      tourist_params
    end

    def set_attrs
      if params[:tourist][:images_attributes]
        params[:tourist][:images_attributes].each do |attrs|
          if attrs[1]["file"] && !attrs[1]["company_id"]
            attrs[1][:company_id] = current_company.id
          end
        end
      end
    end

    def set_images
      @tourist.images.each do |img|
        img.company = current_company if img.file
      end
    end

    def check_offline
      if params[:offline] && params[:id] == '0'
        @tourist = Tourist.new
        @tourist.id = 0
      end
    end

    def checkout_order(options)
      options[:with].merge!(:potential => show_potential_clients)
      if options[:order] == :full_name
        options[:sql_order] = %w[last_name first_name middle_name].map{|f| "#{f} #{options[:sort_mode]}"}.join(',')
      elsif options[:order] == :passport
        options[:sql_order] = %w[passport_series passport_number].map{|f| "#{f} #{options[:sort_mode]}"}.join(',')
      end
    end

    def search_params
      return @search_params if @search_params
      @search_params = {}
      exluded_params = [:controller, :action, :potential]
      params.each do |k, v|
        @search_params[k] = v unless exluded_params.include?(k.to_sym) || v.blank?
      end
      @search_params
    end

    def set_last_search
      session_key = show_potential_clients ? :potential_tourists_last_search : :tourists_last_search
      if params[:unset_filters]
        session[session_key] = nil
      elsif search_or_sort?
        session[session_key] = !search_params.empty? ? search_params : nil;
      elsif session[session_key].present?
        params.reverse_merge!(session[session_key])
      end
    end

    def redirect_to_tourists(is_potential, message_key)
      message = t("tourists.messages.#{is_potential ? 'client_' : ''}#{message_key}")
      unless is_potential
        redirect_to tourists_path, :notice => message
      else
        redirect_to tourists_path(potential: 1), :notice => message
      end
    end

    def check_office(tourist)
      if tourist.potential? && (current_user.office.id != tourist.office_id) && (is_manager? || is_supervisor?)
        redirect_to tourists_path(potential: 1), :alert => I18n.t("tourists.messages.cant_edit")
      end
    end

    def check_address(tourist, is_potential = nil)
      tourist.build_address unless tourist.address || (is_potential.nil? ? tourist.potential? : is_potential)
    end

end
