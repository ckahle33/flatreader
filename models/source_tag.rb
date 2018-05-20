class SourceTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :source
end

