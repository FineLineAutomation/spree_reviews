FactoryGirl.define do
  factory :feedback_review, :class => Spree::FeedbackReview do |f|
    rating { (rand * 4).to_i + 1 }

    association(:user, :factory => :user)
    association(:review, :factory => :review)
  end
end