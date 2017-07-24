Pod::Spec.new do |s|
  s.name         = "Disk"
  s.version      = "0.0.8"
  s.summary      = "Delightful framework for iOS to easily persist structs, images, and data."
  s.description  = <<-DESC
    Easily work with the file system without worrying about any of its intricacies! Store Codable structs, UIImage, [UIImage], Data, [Data] to Apple recommended locations on the user's disk. Retrieve an object from disk as the type you specify, without having to worry about conversion or casting. Remove specific objects from disk, clear entire directories if you need to, or check if an object exists on disk.
  DESC
  s.homepage     = "https://github.com/saoudrizwan/Disk"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Saoud Rizwan" => "hello@saoudmr.com" }
  s.social_media_url   = "https://twitter.com/sdrzn"
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/saoudrizwan/Disk.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/**/*.{h,m,swift}"
end
