require 'spec_helper'

describe ReportController do
  before do
    sign_in alice
    @message = alice.post(:status_message, :text => "hey", :to => alice.aspects.first.id)
    @comment = alice.comment!(@message, "flying pigs, everywhere")
  end

  describe '#index' do
    context 'admin not signed in' do
      it 'is behind redirect_unless_admin' do
        get :index
        response.should redirect_to stream_path
      end
    end
    
    context 'admin signed in' do
      before do
        Role.add_admin(alice.person)
      end
      it 'succeeds and renders index' do
        get :index
        response.should render_template('index')
      end
    end
  end

  describe '#create' do
    let(:comment_hash) {
      {:text    =>"facebook, is that you?",
       :post_id =>"#{@post.id}"}
    }

    context 'report offensive post' do
      it 'succeeds' do
        put :create, :report => { :post_id => @message.id, :post_type => 'post', :text => 'offensive content' }
        response.status.should == 200
        Report.exists?(:post_id => @message.id, :post_type => 'post').should be_true
      end
    end
    context 'report offensive comment' do
      it 'succeeds' do
        put :create, :report => { :post_id => @comment.id, :post_type => 'comment', :text => 'offensive content' }
        response.status.should == 200
        Report.exists?(:post_id => @comment.id, :post_type => 'comment').should be_true
      end
    end
  end

  describe '#update' do
    context 'mark post report as user' do
      it 'is behind redirect_unless_admin' do
        put :update, :id => @message.id, :type => 'post'
        response.should redirect_to stream_path
        Report.where(:reviewed => false, :post_id => @message.id, :post_type => 'post').should be_true
      end
    end
    context 'mark comment report as user' do
      it 'is behind redirect_unless_admin' do
        put :update, :id => @comment.id, :type => 'comment'
        response.should redirect_to stream_path
        Report.where(:reviewed => false, :post_id => @comment.id, :post_type => 'comment').should be_true
      end
    end

    context 'mark post report as admin' do
      before do
        Role.add_admin(alice.person)
      end
      it 'succeeds' do
        put :update, :id => @message.id, :type => 'post'
        response.status.should == 302
        Report.where(:reviewed => true, :post_id => @message.id, :post_type => 'post').should be_true
      end
    end
    context 'mark comment report as admin' do
      before do
        Role.add_admin(alice.person)
      end
      it 'succeeds' do
        put :update, :id => @comment.id, :type => 'comment'
        response.status.should == 302
        Report.where(:reviewed => true, :post_id => @comment.id, :post_type => 'comment').should be_true
      end
    end
  end

  describe '#destroy' do
    context 'destroy post as user' do
      it 'is behind redirect_unless_admin' do
        delete :destroy, :id => @message.id, :type => 'post'
        response.should redirect_to stream_path
        Report.where(:reviewed => false, :post_id => @message.id, :post_type => 'post').should be_true
      end
    end
    context 'destroy comment as user' do
      it 'is behind redirect_unless_admin' do
        delete :destroy, :id => @comment.id, :type => 'comment'
        response.should redirect_to stream_path
        Report.where(:reviewed => false, :post_id => @comment.id, :post_type => 'comment').should be_true
      end
    end

    context 'destroy post as admin' do
      before do
        Role.add_admin(alice.person)
      end
      it 'succeeds' do
        delete :destroy, :id => @message.id, :type => 'post'
        response.status.should == 302
        Report.where(:reviewed => true, :post_id => @message.id, :post_type => 'post').should be_true
      end
    end
    context 'destroy comment as admin' do
      before do
        Role.add_admin(alice.person)
      end
      it 'succeeds' do
        delete :destroy, :id => @comment.id, :type => 'comment'
        response.status.should == 302
        Report.where(:reviewed => true, :post_id => @comment.id, :post_type => 'comment').should be_true
      end
    end
  end
end
