require "spec_helper"

describe Rack::API do
  def app; Rack::API; end

  let(:user)        { create :user }
  let(:json)        { JSON.parse(last_response.body) }
  let(:attributes)  { FactoryGirl.attributes_for(:post).merge({ user_id: user.id }) }

  describe Api::V2::PostsController do
    describe "#index" do
      let!(:posts)  { create_list :post, 5 }

      before { get "api/v2/posts" }

      it { expect(last_response.status).to eql 200 }
      it { expect(json["posts"].length).to eql 5 }
      it { expect(json["posts"].first["title"]).to eql posts.first.title }

    end

    describe "#create" do

      describe "with valid data" do

        before { post "api/v2/posts", post: attributes }

        it { expect( last_response.status ).to eql 201 }
        it { expect( json["post"]["title"] ).to eql attributes[:title] }
        it { expect( Post.count ).to eql 1 }
        it { expect( Post.where(title: attributes[:title]) ).to exist }
        it { expect( user.posts.where(title: attributes[:title]) ).to exist }
      end

      describe "with invalid data" do
        before { post "api/v2/posts", post: {} }

        it { expect( last_response.status ).to eql 400 }
        it { expect( Post.count ).to eql 0 }
      end

    end

    describe "#show" do
      let(:post)        { create :post }
      before { get "api/v2/posts/#{post.id}" }

      it { expect(last_response.status).to eql 200 }
      it { expect(json["post"]["title"]).to eql post.title }
    end

    describe "#update" do
      let(:post) { create :post }

      describe "with valid data" do
        before { put "api/v2/posts/#{post.id}", post: { title: 'New one' } }

        it { expect(last_response.status).to eql 200 }
        it { expect(json["post"]["title"]).to eql 'New one' }
      end

      describe "with invalid data" do
        before { put "api/v2/posts/#{post.id}", post: { title: '' } }

        it { expect(last_response.status).to eql 400 }
      end
    end

    describe "#destroy" do
      let(:post) { create :post }

      before { delete "api/v2/posts/#{post.id}" }

      it { expect(last_response.status).to eql 200 }
      it { expect( Post.where(title: post.title) ).not_to exist }
    end
  end

end
