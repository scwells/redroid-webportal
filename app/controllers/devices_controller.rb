require 'find'

class DevicesController < ApplicationController
  before_filter :validate_query_params, only: [:show, :edit, :update, :destroy]

  # GET /devices
  # GET /devices.json
  def index
    # @devices = Device.all
  end

  # GET /devices/1
  # GET /devices/1.json
  def show
    if params[:search]
      @deviceid = params[:search]
      if File.directory?(file_path = "/home/redroid/video_saves/#{@deviceid}")
        @videos = get_device_directory(@deviceid)
        if (@videos.count == 0)
          flash[:warning] = 'No saved videos found for that device.'
          redirect_to root_path
        else
          @videos.count == 1 ? flash[:info] = "#{@videos.count} video found!" : flash[:info] = "#{@videos.count} videos found!"
        end
      else
        flash[:danger] = "Device: #{@deviceid} not found on the system. Please check ID or contact server administrator."
        redirect_to root_path
      end
    end
  end

  # GET /devices/new
  def new
    @device = Device.new
  end

  # GET /devices/1/edit
  def edit
  end

  def validate_query_params
    if params[:search] && params[:search] !~ /\A(\w)+\z/
      flash[:danger] = 'Invalid device name.'
      redirect_to root_path
    end
    if params[:device] && params[:device] !~ /\A(\w)+\z/
      flash[:danger] = 'Invalid device parameter.'
      redirect_to root_path
    end
    if params[:file] && params[:file] !~ /\A(\w|\d)+[_]([-:\w\d])+(.flv)\z/
      flash[:danger] = 'Invalid file parameter.'
      redirect_to root_path
    end
  end

  def download
    if params[:device] && params[:file]
      if File.exist?(file_path = "/home/redroid/video_saves/#{params[:device]}/#{params[:file]}")
        send_file "/home/redroid/video_saves/#{params[:device]}/#{params[:file]}", disposition: 'attachment'
      else
        redirect_to root_path
      end
    end
  end

  def delete
    if params[:device] && params[:file]
      device = params[:file].split('_').first
      if File.exist?(file_path = "/home/redroid/video_saves/#{device}/#{params[:file]}")
        # first remove file from the system
        File.delete(file_path)
        # clean up sym link
        File.delete("/home/redroid/video_saves/vod_links/#{params[:file]}")
        flash[:success] = "Video was successfully deleted."
      else
        flash[:error] = "Video could not be deleted or not found."
      end
    end
    redirect_to devices_path(search: params[:device])
  end

  # POST /devices
  # POST /devices.json
  def create
    @device = Device.new(device_params)

    respond_to do |format|
      if @device.save
        format.html { redirect_to @device, notice: 'Device was successfully created.' }
        format.json { render :show, status: :created, location: @device }
      else
        format.html { render :new }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /devices/1
  # PATCH/PUT /devices/1.json
  def update
    respond_to do |format|
      if @device.update(device_params)
        format.html { redirect_to @device, notice: 'Device was successfully updated.' }
        format.json { render :show, status: :ok, location: @device }
      else
        format.html { render :edit }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /devices/1
  # DELETE /devices/1.json
  def destroy
    @device.destroy
    respond_to do |format|
      format.html { redirect_to devices_url, notice: 'Device was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = Device.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_params
      params.require(:device).permit(:deviceid, :search, :filepath)
    end

    def video_search(devid)
      # fetch all filenames from the given folder
      return Find.find("/home/redroid/video_saves/#{devid}").map { |path| File.basename path }
    end

    def get_device_directory(device_id)
      if Dir.exist?(file_path = "/home/redroid/video_saves/#{device_id}")
        files = Dir.entries(file_path).select { |e| /\A(\w|\d)+[_]([-:\w\d])+(.flv)\z/ =~ e  }
        files = files.sort_by { |file| File.mtime(file_path + '/' + file) }
        result = []
        files.reverse_each do |file|
          result << { name: file, 
                      size: '%.2f' % (File.size("#{file_path}/#{file}").to_f / 2**20 ) }
        end
        result
      else
        []
      end
    end

end
