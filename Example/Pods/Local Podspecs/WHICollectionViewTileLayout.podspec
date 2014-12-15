#
# Be sure to run `pod lib lint WHICollectionViewTileLayout.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "WHICollectionViewTileLayout"
  s.version          = "0.1.0"
  s.summary          = "A masonry style UICollectionViewLayout."
  s.description      = <<-DESC
                       WHICollectionViewTileLayout is a class to replace UICollectionViewFlowLayout. Instead of floating items and centering different sizes on a row, WHICollectionViewTileLayout snaps UICollectionView cells to a grid. For every index path, provide a WHISpan that designates the number of columns and rows. This enables a rich mix of cell sizes to seamlessly fit into together like pieces of a puzzle. Calculating the tile positions of WHICollectionViewTileLayout is done with C arrays and bit shifting for optimal performance. See the Example app for more details. 
                       DESC
  s.homepage         = "https://github.com/johnnyfuchs/WHICollectionViewTileLayout"
  s.license          = 'MIT'
  s.author           = { "johnnyfuchs" => "johnnyfuchs@gmail.com" }
  s.source           = { :git => "https://github.com/johnnyfuchs/WHICollectionViewTileLayout.git", :tag => s.version.to_s }
  s.social_media_url = 'https://weheartit.com/'
  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/*{h,m}'
end
