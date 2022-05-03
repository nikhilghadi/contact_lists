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
    key_pad={2=>['a','b','c'],3=>['d','e','f'],4=>['g','h','i'],5=>['j','k','l'],
    6=>['m','n','o'],7=>['p','q','r','s'],8=>['t','u','v'],9=>['w','x','y','z']}

    str_text = []
    text.each_char{|i|
      i=i.to_i
      p 'I',i.class
      if (i!=0 and i!=1)
        p "fdf"
        str_text.push( key_pad[i])
      end
    }
    p str_text
    combinations =[]
    #product method  throws error when pass  
    #large number of arrays 
    if(str_text.length < 6)
      #first create  the  catesian product of possible key combination 
      # 
      catesian_product = str_text.shift.product(*str_text)
      
      p "catesian product",catesian_product

      # then join the arrys andcreate the  string  of  arrays
      catesian_product.map{|a|
          combinations.push(a.join)
      
      }
    end
    p "combinations",combinations,str_text
        

   
    list = []
    if(is_integer(text) == false)
      list = Contact.where("lower(contact_name)  like '%#{text}%' ")
      list = list.includes(:phone_numbers).map{|cl| {contact_name:cl.contact_name,numbers:cl.phone_numbers}}
    else
      contacts= []
      if combinations.length
        query = " "
        combinations.each_with_index do|cmb,i|
          if i == combinations.length-1
            query += " lower(contact_name) like '%#{cmb}%'"
          else
            query += "lower(contact_name) like '%#{cmb}%' or "
          end
        end
        l = Contact.where("  #{query} ")
        l = l.includes(:phone_numbers).map{|cl| {contact_name:cl.contact_name,numbers:cl.phone_numbers}}
        contacts = l
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
