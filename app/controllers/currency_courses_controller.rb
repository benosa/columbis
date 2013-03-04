# -*- encoding : utf-8 -*-
class CurrencyCoursesController < ApplicationController
  load_and_authorize_resource

  def index
    @actual_courses = CurrencyCourse.actual_courses
    @currency_courses = CurrencyCourse.order_by_date
  end

  def show
    @currency_course = CurrencyCourse.find(params[:id])
  end

  def new
    @currency_course = CurrencyCourse.new
    @currency_course.on_date = Time.now
  end

  def create
    @currency_course = CurrencyCourse.new(params[:currency_course])
    @currency_course.user = current_user
    if @currency_course.save
      redirect_to currency_courses_url, :notice => "Successfully created currency course."
    else
      render :action => 'new'
    end
  end

  def edit
    @currency_course = CurrencyCourse.find(params[:id])
  end

  def update
    @currency_course = CurrencyCourse.find(params[:id])
    if @currency_course.update_attributes(params[:currency_course])
      redirect_to currency_courses_url, :notice  => "Successfully updated currency course."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @currency_course = CurrencyCourse.find(params[:id])
    @currency_course.destroy
    redirect_to currency_courses_url, :notice => "Successfully destroyed currency course."
  end
end

