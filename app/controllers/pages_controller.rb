class PagesController < ApplicationController
  skip_before_action :verify_authenticity_token
  after_action :add_header, only: :search_contact
  after_action :add_header2, only: :add_new_contact

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
    key_pad={2=>'abc',3=>'def',4=>'ghi',5=>'jkl',6=>'mno',7=>'pqrs',8=>'tuv',9=>'wxyz'}
    str_text = []
    p"text",text
    text.each_char{|i|
      i=i.to_i
      p 'I',i.class
      if (i!=0 and i!=1)
        p "fdf"
        str_text.push( key_pad[i])
      end
    }
    new_str=[]
    if str_text.length > 0
      first_string = str_text[0]
      p "str",str_text
      if str_text.length > 1
        first_string.each_char{|f|
          new_str.push(f+str_text[1][0])
        }
        if str_text.length == 3
          temp =new_str.map{|a| a}
          new_str = []
          temp.each do |d|
            new_str.push(d+str_text[2][0])
          end
        end
      else
        new_str = [first_string[0]]
      end
    end
    new_str =new_str.select{|s| (s!=nil and s!='')}
    p "new_str",new_str
    list = []
    if(is_integer(text) == false)
    list = Contact.where("lower(contact_name)  like '%#{text}%' ")
    list = list.includes(:phone_numbers).map{|cl| {contact_name:cl.contact_name,numbers:cl.phone_numbers}}
    else
      contacts= []
      if new_str.length
        new_str.each do|ns|
          l = Contact.where("lower(contact_name)  like '%#{ns.downcase}%' ")
          l = l.includes(:phone_numbers).map{|cl| {contact_name:cl.contact_name,numbers:cl.phone_numbers}}
          if( l.length and l[0]!=nil)
            contacts.push(l[0])
          end
        end
      end
      p "contacts",contacts
      nums = PhoneNumber.where("phone_number like '%#{text}%' ").map{|num| {contact_name:Contact.find(num.contact_id).contact_name,numbers:PhoneNumber.where(contact_id:num.contact_id)} }
      list =contacts +nums

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
    response.headers['Access-Control-Allow-Origin'] = 'https://amazing-sunshine-8d59e1.netlify.app'
    response.headers['Access-Control-Allow-Methods'] = 'GET'
    response.headers['Access-Control-Expose-Headers'] = ''
    response.headers['Access-Control-Max-Age'] = '7200'

  end

  def add_header2
    p "Adding header2",response.headers
    response.headers['Access-Control-Allow-Origin'] = 'https://amazing-sunshine-8d59e1.netlify.app'
    response.headers['Access-Control-Allow-Methods'] = 'POST'
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
