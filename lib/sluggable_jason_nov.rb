module Sluggable
  extend ActiveSupport::Concern

  included do
    class_attribute :slug_column
    before_save :generate_slug!
  end

  def generate_slug!
    sluggable_col_name = self.class.slug_column.to_s
    sluggable_col_value = self.send(sluggable_col_name).to_s
    slug_url = clean_string(sluggable_col_value)
    obj = self.class.find_by slug: slug_url
    count = 2
    while obj && obj != self
      slug_url = append_suffix(slug_url, count)
      obj = self.class.find_by slug: slug_url
      count += 1
    end
    self.slug = slug_url
  end

  def append_suffix(string, count)
    if string.split("--").last.to_i != 0
      return string.split("--").first + "--" + count.to_s
    else
      return string + "--" + count.to_s
    end
  end

  def clean_string(string)
    string.gsub(/[^0-9a-z ]/i, '').gsub(" ", "-").gsub(/-+/, "-").downcase
  end

  def to_param
    self.slug
  end

  module ClassMethods
    def sluggable_column(col_name)
      self.slug_column = col_name
    end
  end
end
