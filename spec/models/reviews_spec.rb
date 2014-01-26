require 'spec_helper'

describe Spree::Review do
  before(:each) do
    @review = create(:review)
  end

  it "is valid with valid attributes" do
    expect(build(:review)).to be_valid
  end

  it "is not valid without a name" do
    expect(build(:review, :name => "")).to_not be_valid
  end

  it "is not valid without a rating" do
    expect(build(:review, :rating => nil)).to_not be_valid
  end

  it "is not valid unless the rating is an integer" do
    expect(build(:review, :rating => 2.0)).to_not be_valid
  end

  it "is not valid without a review body" do
    expect(build(:review, :review => nil)).to_not be_valid
  end

  context "when recalculating product rating and include_unapproved_reviews is false" do
    let(:product) { create(:product) }
    let(:review) { create(:review, :product => product, :approved => true, :rating => 5) }

    it "sets the prodcut rating to 0 if there are no reviews" do
      review.destroy
      expect(product.reload.avg_rating).to eq(0)
    end

    it "updates the product rating when a review is approved" do
      create(:review, :product => product, :approved => true, :rating => 1)
      expect(review.product.reload.avg_rating).to eq(3)
    end

    it "updates the product rating when a review is destroyed" do
      review2 = create(:review, :product => product, :approved => true, :rating => 1)
      review.destroy
      expect(product.reload.avg_rating).to eq(1)
    end
  end

  context "when calculating feedback stars" do
    let(:review) { create(:review) }

    it "returns zero if there are no feedback reviews" do
      expect(review.feedback_stars).to eq(0)
    end

    it "returns the average rating from all feedback reviews" do
      3.times do |i|
        create(:feedback_review, :review => review, :rating => i+1)
      end
      expect(review.feedback_stars).to eq(2)
    end
  end

  context "when filtering with the approved scope" do
    it "contains reviews that are approved" do
      review = create(:review, :approved => true)
      expect(Spree::Review.approved).to include(review)
    end

    it "does not contain reviews that are unapproved" do
      review = create(:review, :approved => false)
      expect(Spree::Review.approved).to_not include(review)
    end
  end

  context "when filtering with the unapproved scope" do
    it "contains reviews that are unapproved" do
      review = create(:review, :approved => false)
      expect(Spree::Review.not_approved).to include(review)
    end

    it "does not contain reviews that are approved" do
      review = create(:review, :approved => true)
      expect(Spree::Review.not_approved).to_not include(review)
    end
  end

  context "when filtering with the approval_filter scope" do
    it "contains reviews that are approved" do
      review = create(:review, :approved => true)
      expect(Spree::Review.approval_filter).to include(review)
    end

    it "does not contain reviews that are unapproved when include_unapproved_reviews is false" do
      Spree::Reviews::Config[:include_unapproved_reviews] = false
      review = create(:review, :approved => false)
      expect(Spree::Review.approval_filter).to_not include(review)
    end

    it "contains reviews that are unapproved when include_unapproved_reviews is true" do
      Spree::Reviews::Config[:include_unapproved_reviews] = true
      review = create(:review, :approved => false)
      expect(Spree::Review.approval_filter).to include(review)
    end
  end
end
