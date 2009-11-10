module Slugify
  class SlugGenerator
    CHAR_ENCODING_TRANSLATION_TO   = 'ascii//ignore//translit'
    CHAR_ENCODING_TRANSLATION_FROM = 'utf-8'
    DEFAULT_SLUG_COLUMN            = "default"
    
    class << self
      def generate_slug(str)
        str = Iconv.iconv(CHAR_ENCODING_TRANSLATION_TO, CHAR_ENCODING_TRANSLATION_FROM, str).to_s
        str.downcase!
        
        str.gsub! /<.*?>/,                       ''   # strip HTML
        str.gsub! /[\'\"\#\$\,\.\!\?\%\@\(\)]+/, ''
        str.gsub! /\&/,                          'and'
        str.gsub! /\_/,                          '-'
        str.gsub! /[\W^-_]+/,                    '-'
        str.gsub! /(\-)+/,                       '-'
        str
      end

      def generate(obj)
        new(obj).generate_slug
      end
      
      def regenerate(obj)
        new(obj).regenerate_slug
      end
    end

    def initialize(obj)
      @obj = obj
    end

    def generate_slug
      generate_slug_without_checking_proc if generate_slug?
    end
    
    def regenerate_slug
      generate_slug_without_checking_proc
    end
    
    def generate_slug_without_checking_proc
      slug_value = source_slug_value
 
      if !slug_value.blank?
        escaped_string = cleanup_slug(slug_value.dup)
        
        if !escaped_string.blank?
          set_unique_slug_value(escaped_string)
        else
          set_unique_slug_value(DEFAULT_SLUG_COLUMN)
        end
      end
    end

    def generate_slug?
      slugify_proc && slugify_proc.call(@obj) ? true : false
    end

    def slug_exists?
      !slug.blank?
    end

  private

    def build_conditions(slug_value)
      sql_str, values = "#{slug_column} = ?", [slug_value]

      scopes.each do |column_name|
        sql_str << " AND #{column_name} = ?"
        values  << scope_value(column_name)
      end

      if @obj.id
        sql_str << " AND id != ?"
        values  << @obj.id
      end

      [sql_str, *values]
    end

    def cleanup_slug(str)
      self.class.generate_slug(str)
    end

    def set_unique_slug_value(slug_value)
      original_slug_value = slug_value
      counter = 0

      while true
        if count(:conditions => build_conditions(slug_value)) == 0
          self.slug = slug_value
          break
        else
          slug_value = "#{original_slug_value}-#{counter}"
          counter += 1
        end
      end
    end

    def scope?
      scope ? true : false
    end

    def scopes
      @obj.class.slug_scope
    end

    def scope_value(scope_column)
      @obj.send(scope_column)
    end

    def slug
      @obj.send(slug_column)
    end

    def slug=(value)
      @obj.send("#{slug_column}=", value)
    end

    def count(*args)
      @obj.class.count(*args)
    end

    def source_slug_value
      @obj.send(source_slug_column)
    end

    def source_slug_column
      @obj.class.source_slug_column
    end

    def slug_column
      @obj.class.slug_column
    end

    def slugify_proc
      @obj.class.slugify_when
    end
  end
end
