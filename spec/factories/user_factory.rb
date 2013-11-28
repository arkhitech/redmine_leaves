#FactoryGirl.define do
#  factory :user do
#    sequence( :email ) { |n| "foo#{n}@example.com" }
#    password              'foobar'
#    password_confirmation 'foobar'
#    created_at            Time.now
#    updated_at            Time.now
#  end
#end