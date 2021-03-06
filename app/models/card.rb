# == Schema Information
# Table name: cards
#
#  id                     :integer          not null, primary key
#  default                :boolean          not null, default(false)
#  last4                  :string           not null
#  stripe_id              :string           not null
#  user_id                :integer          not null, foreign key

# Stores card attributes that are pushed over to Stripe while handling Stripe
# Card creation. This is to reduce calls to Stripe's API while having the
# ability to show the user basic card information.
class Card < ApplicationRecord
  belongs_to :user

  validates :last4, presence: true
  validates :stripe_id, presence: true
  validates :user, presence: true
end
