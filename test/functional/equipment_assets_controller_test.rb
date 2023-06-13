require File.dirname(__FILE__) + '/../test_helper.rb'
require 'equipment_assets_controller'

# Re-raise errors caught by the controller.
#class EquipmentAssetsController; def rescue_action(e) raise e end; end

class EquipmentAssetsControllerTest < ActionController::TestCase
  fixtures :equipment_assets, :asset_check_ins

  def setup
    #@controller = EquipmentAssetsController.new
    #@request    = ActionController::TestRequest.new
    #@response   = ActionController::TestResponse.new
    @user = User.generate_with_protected!(:admin => true)
    @request.session[:user_id] = @user.id
  end

  should_route :get, "/equipment_assets", :action => :index
  should_route :get, "/equipment_assets/1", :action => :show, :id => 1
  should_route :get, "/equipment_assets/new", :action => :new
  should_route :post, "/equipment_assets", :action => :create
  should_route :get, "/equipment_assets/1/edit", :action => :edit, :id => 1
  should_route :put, "/equipment_assets/1", :action => :update, :id => 1
  should_route :delete, "/equipment_assets/1", :action => :destroy, :id => 1
  should "route '/equipment_assets/1/print' to print" do
    assert_recognizes({:controller => "equipment_assets", :action => "print", :id => "1"}, "/equipment_assets/1/print")
  end
  should_route :put, "/equipment_assets/print", :action => :print
  should_route :get, "/equipment_assets/print/all", :action => :print, :id => "all"
  should "route '/equipment_assets/print/all' to print" do
    assert_recognizes({:controller => "equipment_assets", :action => "print", :id => "all"}, "/equipment_assets/all/print")
  end

  %(none asset_type location).each do |test_setting|
    context "When asset_grouped_by == #{test_setting}" do
      setup do
        # Re-define the method to stub out the
        # Setting.plugin_redmine_equipment_status_viewer logic
        module EquipmentAssetsHelper
          def asset_grouped_by
            "#{test_setting}"
          end
        end
        # Create a sorted_by check for arrays
        class Array
          def sorted_by?(method)
            self.each_cons(2) do |a|
              return false if a[0].send(method) > a[1].send(method)
            end
            true
          end
        end
      end
      context "GET :index" do
        setup do
          get :index
        end
        should_respond_with :success
        should_assign_to :equipment_assets
        # Can't even tell if this is working code due to issue #39
        # I f*cking hate Ruby versions! Dear God will someone help me?!
        if test_setting != 'none'
          should "sort :equipment_assets by #{test_setting}" do
            assert @equipment_assets.sorted_by?(test_setting.to_sym)
          end
        end
        should_assign_to :asset_check_ins
        should_assign_to :groups
        should_render_template :index
      end
    end
  end

  context "GET :new" do
    setup do
      get :new
    end
    should_respond_with :success
    should_render_template :new
  end
  
  context "POST :create" do
    setup do
      @old_count = EquipmentAsset.count
      post :create, :equipment_asset => { :name => "foo" }
    end
    should "increase count by 1" do
      assert EquipmentAsset.count - @old_count == 1
    end
    should_redirect_to(":show") { equipment_asset_path(EquipmentAsset.last) }
  end

  context "GET :show" do
    setup do
      get :show, :id => 1
    end
    should_respond_with :success
    should_render_template :show
  end

  context "GET :edit" do
    setup do
      get :edit, :id => 1
    end
    should_respond_with :success
    should_assign_to :equipment_asset
    should_render_template :edit
  end
  
  context "PUT :update" do
    setup do
      put :update, :id => 1, :equipment_asset => { }
    end
    should_redirect_to(":show") { equipment_asset_path(EquipmentAsset.find(1)) }
  end
  
  context "GET :destroy" do
    setup do
      @old_count = EquipmentAsset.count
      delete :destroy, :id => 1
    end
    should "decrease count by 1" do
      assert EquipmentAsset.count - @old_count == -1
    end
    should_redirect_to(":index") { equipment_assets_path }
  end

  context "GET :print" do
    setup do
      get :print, :id => 1
    end
    should_respond_with :success
    should_assign_to :equipment_asset
    should_render_template :print
  end

  context "GET :print all" do
    setup do
      get :print, :id => "all"
    end
    should_respond_with :success
    should_assign_to :equipment_assets
    should_render_template :printm
  end

  context "POST :printm" do
    setup do
      put :print, :asset_ids => [1,2,3,5]
    end
    should_respond_with :success
    should_assign_to :equipment_assets
    should_render_template :printm
  end
end
