# encoding: utf-8

class FileUploader < CarrierWave::Uploader::Base

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  #Add a white list of extensions which are allowed to be uploaded.
  #For images you might use something like this:
  def extension_white_list
    %w(*)
  end

  # A string of file extensions acceptable for the uploader.
  # (passed to uploadify)
  #
  def file_ext(delimiter= ';')
    extension_white_list.map {|ext| "*.#{ext}" }.join(delimiter)
  end

  # Description of file types acceptable for the uploader
  # (passed to uploadify)
  #
  def file_desc
    "All Files (#{file_ext(',')})"
  end

  def filename
    super.presence || path.present? && path.split('/').last
  end
end
