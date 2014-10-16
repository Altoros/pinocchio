require "spec_helper"

describe Rack::API do
  def app; Rack::API; end

  let(:user)        { create :user }
  let(:json)        { JSON.parse(last_response.body) }
  let(:attributes)  { FactoryGirl.attributes_for(:post).merge({ user_id: user.id }) }

  describe Api::V2::PostsController do
    describe "#index" do
      let!(:posts)  { create_list :post, 5 }

      it "renders the json index" do
        get 'api/v2/posts'

        expect( last_response.status ).to eql 200
        expect(json).to have_key('posts')
        expect(json['posts'].size).to eql 5
      end

      it "paginate items" do
        get 'api/v2/posts', { page: 1, per_page: 1 }

        expect( last_response.status ).to eql 200
        expect(json).to have_key('posts')
        expect(json['posts'].size).to eq(1)
      end

      it "filter items with simple query" do
        post_to_search = create(:post, title: "To Search")

        get 'api/v2/posts', { page: 1, query: post_to_search.title }

        expect( last_response.status ).to eql 200
        expect(json).to have_key('posts')
        expect(json['posts'].size).to eq(1)
        expect(json['posts'][0]).to eq(active_record_to_json post_to_search)
        expect(json['posts']).to include(active_record_to_json post_to_search)
      end

      it "filter items with simple query_2" do
        post_to_search = create(:post, title: "To Search")
        post_to_search_2 = create(:post, body: "To Search 2")

        get 'api/v2/posts', { page: 1, query: "To Sea" }

        expect( last_response.status ).to eql 200
        expect(json).to have_key('posts')
        expect(json['posts'].size).to eq(2)
        expect(json['posts']).to include(active_record_to_json post_to_search)
        expect(json['posts']).to include(active_record_to_json post_to_search_2)
      end

      it "filter items with simple query and order by title" do
        post_to_search = create(:post, title: "To Search")
        post_to_search_2 = create(:post, title: "AAA", body: "To Search 2")

        get 'api/v2/posts', { page: 1, query: "To Sea", order_by: "title", order_type: "asc" }

        expect( last_response.status ).to eql 200
        expect(json).to have_key('posts')
        expect(json['posts'].size).to eq(2)
        expect(json['posts'][1]).to eq(active_record_to_json post_to_search)
        expect(json['posts'][0]).to eq(active_record_to_json post_to_search_2)
      end

      it "filter posts using user attributes" do
        user_to_search = create(:user, email: "test_email_search@test.com")
        post_to_search = create(:post, title: "To Search", user: user_to_search)

        get 'api/v2/posts', { page: 1, query: user_to_search.email, order_by: "title", order_type: "asc" }

        expect( last_response.status ).to eql 200
        expect(json).to have_key('posts')
        expect(json['posts'].size).to eq(1)
        expect(json['posts'][0]).to eq(active_record_to_json post_to_search)
      end

    end

    describe "#create" do

      describe "with valid data" do

        before { post "api/v2/posts", { post: attributes } }

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
      let(:post) { create :post, user: user }

      describe "with valid data" do
        before do
          put "api/v2/posts/#{post.id}", { post: { title: 'New one' } },
            { "Cookie" => "auth_token=#{post.user.auth_token}" }
        end

        it { expect(last_response.status).to eql 200 }
        it { expect(json["post"]["title"]).to eql 'New one' }
      end

      describe "with invalid data" do

        describe "authorized" do
          before {
            put "api/v2/posts/#{post.id}", { post: { title: '' } },
              { "Cookie" => "auth_token=#{post.user.auth_token}" }
          }

          it { expect(last_response.status).to eql 400 }
        end

        describe "unauthorized" do
          before { put "api/v2/posts/#{post.id}", post: { title: '' } }

          it { expect(last_response.status).to eql 401 }
        end
      end
    end

    describe "#destroy" do
      let(:post) { create :post, user: user }

      before { delete "api/v2/posts/#{post.id}", {}, { "Cookie" => "auth_token=#{post.user.auth_token}" } }

      it { expect(last_response.status).to eql 200 }
      it { expect( Post.where(title: post.title) ).not_to exist }
    end
  end

end
