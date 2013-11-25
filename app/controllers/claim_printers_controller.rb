# -*- encoding : utf-8 -*-
class ClaimPrintersController < ApplicationController

  def edit
    if %w[contract memo permit warranty act].include? params[:printer]
      @claim = Claim.find(params[:claim_id])
      html = get_claim_html
      @html_parts = get_html_parts(html)
      render text: nil, layout: 'printer'
    else
      redirect_to claims_url, :alert => "#{t('print_partial_not_found')} '#{params[:form]}'"
    end
  end

  def update
    @claim = Claim.find(params[:claim_id])
    html = get_claim_html
    check_claim_dir
    path = form_path

    page = Nokogiri::HTML(html)
    page_part = page.at_css('body')
    page_part.inner_html = params[:body]
    IO.write(path, page.to_html)
    render text: nil, layout: false
  end

  def print
    @claim = Claim.find(params[:claim_id])
    html = get_claim_html
    render text: html, layout: false
  end

  private
    def get_claim_html
      html = check_form_file
      html = @claim.send(:"print_#{params[:printer]}") if !html
      html
    end

    def check_claim_dir
      dir_path = form_path(false)
      FileUtils.mkdir_p(dir_path) if !File.directory?(dir_path)
    end

    def check_form_file
      path = form_path
      if File.exist?(path)
         IO.read(path)
      else
        false
      end
    end

    def get_html_parts(html)
      page = Nokogiri::HTML(html)
      { head: page.at_css('head').inner_html, body: page.at_css('body').inner_html }
    end

    def form_path(file = true)
      if file
        "uploads/#{@claim.company.id}/claims/#{@claim.id}/#{params[:printer]}.html"
      else
        "uploads/#{@claim.company.id}/claims/#{@claim.id}"
      end
    end

end