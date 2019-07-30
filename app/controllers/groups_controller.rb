class GroupsController < ApplicationController
  before_action :authenticate_user! , only: [:new, :create, :edit, :update, :destroy, :quit, :join]
  before_action :find_group_and_check_permission , only: [:edit, :update, :destroy]

  def index
      @groups =Group.all
  end

  def new 
      @group =Group.new
  end

  def create
    @group = Group.new(group_params)
    @group.user = current_user
    if @group.save
      current_user.join!(@group)
      redirect_to groups_path
    else
      render :new
    end
  end

  def show
    @group=Group.find(params[:id])
    @posts=@group.posts.recent.paginate(:page => params[:page], :per_page => 5)
  end

  def edit
  end

  def update
    if @group.update_attributes(group_params)
      redirect_to groups_path, notice: "Update Success"
    else 
      render :edit
    end
  end

  def destroy
    @group.destroy
    flash[:alert]= "Group deleted"

    redirect_to groups_path
  end

  def join
    @group=Group.find(params[:id])
    if !current_user.is_member_of?(@group)
        current_user.join!(@group)
        flash[:notice]="成功加入板块！"
    else
      flash[:notice]="你已经是板块成员了！"
    end

    redirect_to(@group)
  end  

  def quit
     @group=Group.find(params[:id])
     if current_user.is_member_of?(@group)
        current_user.quit!(@group)
        flash[:notice]="成功推出该板块！"
     else
        flash[:notice]="你不是改板块成员！"
     end

     redirect_to(@group)
  end
  private
    def group_params
      params.require(:group).permit(:title,:description)
    end

    def find_group_and_check_permission
      @group = Group.find(params[:id])

      if current_user !=@group.user
        redirect_to root_path, alert:"You have no permission."
      end
    end

end
