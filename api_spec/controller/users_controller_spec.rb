require "spec_helper"

describe Rack::API do
  def app; Rack::API; end

  let(:json)    { JSON.parse(last_response.body) }
  let(:attributes) { FactoryGirl.attributes_for(:user) }

  describe Api::V2::UserController do
    describe "#index" do
      let!(:users)  { create_list :user, 5 }

      before { get "api/v2/users" }

      it { expect(last_response.status).to eql 200 }
      it { expect(json["users"].length).to eql 5 }
      it { expect(json["users"].first["email"]).to eql users.first.email }

    end

    describe "#create" do

      describe "with valid data" do

        before { post "api/v2/users", user: attributes }

        it { expect( last_response.status ).to eql 200 }
        it { expect( json["user"]["email"] ).to eql attributes[:email] }
        it { expect( User.count ).to eql 1 }
        it { expect( User.where(email: attributes[:email]) ).to exist }
      end

      describe "with invalid data" do
        before { post "api/v2/users", user: {} }

        it { expect( last_response.status ).to eql 500 }
        it { expect( User.count ).to eql 0 }
      end

    end

    describe "#show" do
      let(:user) { create :user }
      before { get "api/v2/users/#{user.id}" }

      it { expect(last_response.status).to eql 200 }
      it { expect(json["user"]["email"]).to eql user.email }
    end

    describe "#update" do
      let(:user) { create :user }

      describe "with valid data" do
        before { put "api/v2/users/#{user.id}", user: { email: 'new@next.com' } }

        it { expect(last_response.status).to eql 200 }
        it { expect(json["user"]["email"]).to eql 'new@next.com' }
      end

      describe "with invalid data" do
        before { put "api/v2/users/#{user.id}", user: { email: '' } }

        it { expect(last_response.status).to eql 500 }
      end
    end

    describe "#destroy" do
      let(:user) { create :user }

      before { delete "api/v2/users/#{user.id}" }

      it { expect(last_response.status).to eql 200 }
      it { expect( User.where(email: user.email) ).not_to exist }


    end
  end

end
