# -*- encoding : utf-8 -*-
class NotesController < ApplicationController
  load_and_authorize_resource
  def new
    @note = Note.new(:item_id => params[:item_id])
  end

  def create
    @note = Note.new(params[:note])

    respond_to do |format|
      if @note.save
        format.html { redirect_to @note, :notice => 'Note was successfully created.' }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    @note = Note.find(params[:id])
  end

  def update
    @note = Note.find(params[:id])

    respond_to do |format|
      if @note.update_attributes(params[:note])
        format.html { redirect_to @note, :notice => 'Note was successfully updated.' }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def index
    @items = Note.find(:all)
  end

  def show
    @item = Note.find(params[:id])
  end

  def destroy
    @note = Note.find(params[:id])
    @note.destroy

    respond_to do |format|
      format.html { redirect_to notes_url }
    end
  end
end
