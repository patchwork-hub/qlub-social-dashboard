class Form::MasterAdmin
  include ActiveModel::Model

  attr_accessor :id, :display_name, :username, :email, :password, :password_confirmation, :note, :role

  def initialize(attributes = {})
    super(attributes.to_h.symbolize_keys)
  end

  def save
    ActiveRecord::Base.transaction do
      account = create_or_update_account!
      create_or_update_user!(account)
    end
    true
  rescue ActiveModel::ValidationError => e
    errors.merge!(e.model.errors)
    false
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.record.errors.full_messages.join(", "))
    false
  end

  def update(params)
    self.attributes = params
    save
  end

  private

  def create_or_update_account!
    Account.where(username: username).first_or_initialize.tap do |account|
      account.assign_attributes(
        username: username,
        display_name: display_name,
        note: note
      )

      unless account.valid?
        raise ActiveModel::ValidationError.new(account)
      end

      account.save!
    end
  end

  def create_or_update_user!(account)
    role_record = UserRole.find_by!(name: 'MasterAdmin')

    user = User.where(email: email).first_or_initialize
    user.assign_attributes(
      email: email,
      password: password,
      password_confirmation: password_confirmation,
      confirmed_at: Time.current,
      role: role_record,
      account: account,
      agreement: true,
      approved: true
    )

    unless user.valid?
      raise ActiveModel::ValidationError.new(user)
    end

    user.save!
  end

end
