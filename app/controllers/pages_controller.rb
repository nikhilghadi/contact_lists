class PagesController < ApplicationController
  skip_before_action :verify_authenticity_token
  after_action :add_header, only: :search_contact
  def index
    p "HERE"
  end


  def is_integer(text)
    p "text",text
    text.to_i.to_s == text
  end

  def search_contact
    p "search_contact",params[:text]
    text = params[:text].downcase

    list = []
    if(is_integer(text) == false)
    list = Contact.where("lower(contact_name)  like '%#{text}%' ")
    list = list.includes(:phone_numbers).map{|cl| {contact_name:cl.contact_name,numbers:cl.phone_numbers}}
    else
      list = PhoneNumber.where("phone_number like '%#{text}%' ").map{|num| {contact_name:Contact.find(num.contact_id).contact_name,numbers:PhoneNumber.where(contact_id:num.contact_id)} }
    end
    render json:list
    
  end

  def  add_new_contact
    p "add_new_contact",params[:data]
    data = params[:data]
    con = Contact.find_by(contact_name:data[:name])
    if (!con.present?)
      Contact.transaction do
          @contact = Contact.new(contacts_params(data))
          if @contact.save
            @phone_number = PhoneNumber.new(phone_params(data))
            if @phone_number.save
              render json:"Done"
            else
              render json: {
                error: @phone_number.errors
              },status: :unprocessable_entity
              raise ActiveRecord::Rollback
              return
            end
          else
            render json: {
                error: @phone_number.errors
              },status: :unprocessable_entity
              raise ActiveRecord::Rollback
              return
          end
      end
    else
      @contact = con
      @phone_number = PhoneNumber.new(phone_params(data))
      if @phone_number.save
        render json:"Done"

      else
        render json: {
                error: @phone_number.errors
              },status: :unprocessable_entity
              raise ActiveRecord::Rollback
              return
      end
    end
  end

  def add_header
    p "Adding header",response.headers
    response.headers['Access-Control-Allow-Origin'] = 'https://amazing-sunshine-8d59e1.netlify.app/'
    response.headers['Access-Control-Allow-Methods'] = 'GET'
    response.headers['Access-Control-Expose-Headers'] = ''
    response.headers['Access-Control-Max-Age'] = '7200'

  end
  private
  def contacts_params(data)
      record = Hash.new
      record['contact_name'] = data['name']
      record
  end

  def phone_params(data)
    record = Hash.new
    record['phone_number'] = data['number']
    record['contact_id'] = @contact.id
    record
  end
end
