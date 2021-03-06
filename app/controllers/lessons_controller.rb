class LessonsController < ApplicationController
  before_action :require_admin!, except: :show
  before_action :set_lesson, only: %i[show edit update destroy]
  before_action :set_stack, only: %i[new edit]

  # GET /lessons
  # GET /lessons.json
  def index
    @lessons = Lesson.all.sort_by(&:position)
  end

  # GET /lessons/1
  # GET /lessons/1.json
  def show
    @stack = @lesson.stack
  end

  # GET /lessons/new
  def new
    @lesson = Lesson.new
  end

  # GET /lessons/1/edit
  def edit; end

  # POST /lessons
  # POST /lessons.json
  def create
    @lesson = Lesson.new(lesson_params)

    respond_to do |format|
      if @lesson.save
        format.html { redirect_to @lesson, notice: 'Lesson was successfully created.' }
        format.json { render :show, status: :created, location: @lesson }
      else
        format.html { render :new }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lessons/1
  # PATCH/PUT /lessons/1.json
  def update
    respond_to do |format|
      if @lesson.update(lesson_params)
        format.html { redirect_to @lesson, notice: "Lesson was successfully updated. #{undo_link}" }
        format.json { render :show, status: :ok, location: @lesson }
      else
        format.html { render :edit }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lessons/1
  # DELETE /lessons/1.json
  def destroy
    @lesson.destroy
    respond_to do |format|
      format.html { redirect_to @lesson.stack, notice: "Lesson was successfully destroyed. #{undo_link}" }
      format.json { head :no_content }
    end
  end

  # handle image posts to s3
  def images
    file = params[:file]
    s3 = Aws::S3::Client.new
    response = s3.put_object(body: file.tempfile, bucket: ENV['S3_BUCKET_NAME'], key: file.original_filename, acl: 'public-read')
    if s3.get_object(bucket: ENV['S3_BUCKET_NAME'], key: file.original_filename) # ensure file persisted
      render json: {
        image: { url: view_context.image_url("https://s3-us-west-1.amazonaws.com/#{ENV['S3_BUCKET_NAME']}/#{file.original_filename}") }
      }, content_type: 'text/html'
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_lesson
    @lesson = Lesson.find(params[:id])
  end

  def set_stack
    @stack = @lesson&.stack || Stack.find(params[:stack_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def lesson_params
    params.require(:lesson).permit(:title, :body, :position, :user_id, :stack_id)
  end

  def authenticate_admin!
    redirect_to root_path unless current_user&.admin?
  end

  def check_subscription
    return if current_user.active?
    redirect_to billing_path unless current_user.active?
  end

  def undo_link
    view_context.link_to('Undo', revert_version_path(@lesson.versions.scope.last), method: :post)
  end
end
