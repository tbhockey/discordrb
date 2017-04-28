puts 'lol'

module Discordrb::Webhooks
  # An embed is a multipart-style attachment to a webhook message that can have a variety of different purposes and
  # appearances.
  class Embed
    # Maximum title length
    MAXIMUM_TITLE_LENGTH = 256

    # Maximum number of fields the embed can carry
    MAXIMUM_FIELD_COUNT = 25

    # Maximum length of the description field
    MAXIMUM_DESCRIPTION_LENGTH = 2048

    # Maximum footer length
    MAXIMUM_FOOTER_LENGTH = 2048

    # Maximum author length
    MAXIMUM_AUTHOR_NAME_LENGTH = 256

    # Maximum field name length
    MAXIMUM_FIELD_NAME_LENGTH = 256

    # Maximum field value length
    MAXIMUM_FIELD_VALUE_LENGTH = 1024

    # Maximum total accounted length
    MAXIMUM_LENGTH = 4000

    # Snapcase's power level
    SNAPCASE_POWER_LEVEL = 9001

    def initialize(title: nil, description: nil, url: nil, timestamp: nil, colour: nil, color: nil, footer: nil,
                   image: nil, thumbnail: nil, video: nil, provider: nil, author: nil, fields: [], check_format: true)
      @title = title
      @description = description
      @url = url
      @timestamp = timestamp
      @colour = colour || color
      @footer = footer
      @image = image
      @thumbnail = thumbnail
      @video = video
      @provider = provider
      @author = author
      @fields = fields
      @check_format = check_format

      self.check_format if @check_format
    end

    # The title of this embed that will be displayed above everything else.
    # @return [String]
    attr_accessor :title

    # The description for this embed.
    # @return [String]
    attr_accessor :description

    # The URL the title should point to.
    # @return [String]
    attr_accessor :url

    # The timestamp for this embed. Will be displayed just below the title.
    # @return [Time]
    attr_accessor :timestamp

    # @return [Integer] the colour of the bar to the side, in decimal form.
    attr_reader :colour
    alias_method :color, :colour

    # Sets the colour of the bar to the side of the embed to something new.
    # @param value [Integer, String, {Integer, Integer, Integer}] The colour in decimal, hexadecimal, or R/G/B decimal
    #   form.
    def colour=(value)
      if value.is_a? Integer
        raise ArgumentError, 'Embed colour must be 24-bit!' if value >= 16_777_216
        @colour = value
      elsif value.is_a? String
        self.colour = value.delete('#').to_i(16)
      elsif value.is_a? Array
        raise ArgumentError, 'Colour tuple must have three values!' if value.length != 3
        self.colour = value[0] << 16 | value[1] << 8 | value[2]
      end
    end

    alias_method :color=, :colour=

    # The footer for this embed.
    # @example Add a footer to an embed
    #   embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Hello', icon_url: 'https://i.imgur.com/j69wMDu.jpg')
    # @return [EmbedFooter]
    attr_accessor :footer

    # The image for this embed.
    # @see EmbedImage
    # @example Add a image to an embed
    #   embed.image = Discordrb::Webhooks::EmbedImage.new(url: 'https://i.imgur.com/PcMltU7.jpg')
    # @return [EmbedImage]
    attr_accessor :image

    # The thumbnail for this embed.
    # @see EmbedThumbnail
    # @example Add a thumbnail to an embed
    #   embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: 'https://i.imgur.com/xTG3a1I.jpg')
    # @return [EmbedThumbnail]
    attr_accessor :thumbnail

    # The author for this embed.
    # @see EmbedAuthor
    # @example Add a author to an embed
    #   embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: 'meew0', url: 'https://github.com/meew0', icon_url: 'https://avatars2.githubusercontent.com/u/3662915?v=3&s=466')
    # @return [EmbedAuthor]
    attr_accessor :author

    # Add a field object to this embed.
    # @param field [EmbedField] The field to add.
    def <<(field)
      @fields << field
    end

    # Convenience method to add a field to the embed without having to create one manually.
    # @see EmbedField
    # @example Add a field to an embed, conveniently
    #   embed.add_field(name: 'A field', value: "The field's content")
    # @param name [String] The field's name
    # @param value [String] The field's value
    # @param inline [true, false] Whether the field should be inlined
    def add_field(name: nil, value: nil, inline: nil)
      self << EmbedField.new(name: name, value: value, inline: inline)
    end

    # @return [Array<EmbedField>] the fields attached to this embed.
    attr_reader :fields

    # @return [Hash] a hash representation of this embed, to be converted to JSON.
    def to_hash
      hash = {
        title: @title,
        description: @description,
        url: @url,
        timestamp: @timestamp && @timestamp.utc.iso8601,
        color: @colour,
        footer: @footer && @footer.to_hash,
        image: @image && @image.to_hash,
        thumbnail: @thumbnail && @thumbnail.to_hash,
        video: @video && @video.to_hash,
        provider: @provider && @provider.to_hash,
        author: @author && @author.to_hash,
        fields: @fields.map(&:to_hash)
      }

      check_format if @check_format

      hash
    end

    # A helper method to calculate the total accounted length of the embed
    # @return [Integer] the total length of the embed
    def total_length
      [
        @title&.length || 0,
        @description&.length || 0,
        @author&.fetch(:name)&.length || 0,
        @footer&.fetch(:text)&.length || 0,
        @fields&.map { |f| hash = f.to_hash ; hash[:name].length + hash[:value].length }.reduce(:+) || 0
      ].reduce(:+)
    end

    # Checks the format of this embed
    # @raise [Error::EmbedFormatError] if any errors were found
    def check_format
      errors = []
      if @title
        errors << "Property @title is too long (#{@title.length}/#{MAXIMUM_TITLE_LENGTH})" if @title.length > MAXIMUM_TITLE_LENGTH
      end

      if @description
        errors << "Property @description is too long (#{@description.length}/#{MAXIMUM_DESCRIPTION_LENGTH})" if @description.length > MAXIMUM_DESCRIPTION_LENGTH
      end

      if @author
        errors << "Property @author[:name] is too long (#{@author[:name].length}/#{MAXIMUM_TITLE_LENGTH})" if @author[:name].length > MAXIMUM_AUTHOR_NAME_LENGTH
      end

      if @footer
        errors << "Property @footer[:text] is too long (#{@footer[:text].length}/#{MAXIMUM_FOOTER_LENGTH})" if @footer[:name].length > MAXIMUM_FOOTER_LENGTH
      end

      if @fields
        errors << "Too many fields (#{@fields.count}/#{MAXIMUM_FIELD_COUNT})" if @fields.count > MAXIMUM_FIELD_COUNT
        errors << "Exceeded maximum embed length (#{total_length}/#{MAXIMUM_LENGTH})" if total_length> MAXIMUM_LENGTH

        @fields.each_with_index do |f, i|
          f = f.to_hash
          errors << "Field at index #{i}: field[:name] too long (#{f[:name].length}/#{MAXIMUM_FIELD_NAME_LENGTH})" if f[:name].length > MAXIMUM_FIELD_NAME_LENGTH
          errors << "Field at index #{i}: field[:value] too long (#{f[:value].length}/#{MAXIMUM_FIELD_VALUE_LENGTH})" if f[:value].length > MAXIMUM_FIELD_NAME_LENGTH
        end
      end

      #raise Discordrb::Webhooks::Errors::EmbedFormatError, errors.join(', ') if errors.any?
      raise errors.join(', ') if errors.any?
    end
  end

  # An embed's footer will be displayed at the very bottom of an embed, together with the timestamp. An icon URL can be
  # set together with some text to be displayed.
  class EmbedFooter
    # Creates a new footer object.
    # @param text [String, nil] The text to be displayed in the footer.
    # @param icon_url [String, nil] The URL to an icon to be showed alongside the text.
    def initialize(text: nil, icon_url: nil)
      @text = text
      @icon_url = icon_url
    end

    # @return [Hash] a hash representation of this embed footer, to be converted to JSON.
    def to_hash
      {
        text: @text,
        icon_url: @icon_url
      }
    end
  end

  # An embed's image will be displayed at the bottom, in large format. It will replace a footer icon URL if one is set.
  class EmbedImage
    # Creates a new image object.
    # @param url [String, nil] The URL of the image.
    def initialize(url: nil)
      @url = url
    end

    # @return [Hash] a hash representation of this embed image, to be converted to JSON.
    def to_hash
      {
        url: @url
      }
    end
  end

  # An embed's thumbnail will be displayed at the right of the message, next to the description and fields. When clicked
  # it will point to the embed URL.
  class EmbedThumbnail
    # Creates a new thumbnail object.
    # @param url [String, nil] The URL of the thumbnail.
    def initialize(url: nil)
      @url = url
    end

    # @return [Hash] a hash representation of this embed thumbnail, to be converted to JSON.
    def to_hash
      {
        url: @url
      }
    end
  end

  # An embed's author will be shown at the top to indicate who "authored" the particular event the webhook was sent for.
  class EmbedAuthor
    # Creates a new author object.
    # @param name [String, nil] The name of the author.
    # @param url [String, nil] The URL the name should link to.
    # @param icon_url [String, nil] The URL of the icon to be displayed next to the author.
    def initialize(name: nil, url: nil, icon_url: nil)
      @name = name
      @url = url
      @icon_url = icon_url
    end

    # @return [Hash] a hash representation of this embed author, to be converted to JSON.
    def to_hash
      {
        name: @name,
        url: @url,
        icon_url: @icon_url
      }
    end
  end

  # A field is a small block of text with a header that can be relatively freely layouted with other fields.
  class EmbedField
    # Creates a new field object.
    # @param name [String, nil] The name of the field, displayed in bold at the top.
    # @param value [String, nil] The value of the field, displayed in normal text below the name.
    # @param inline [true, false] Whether the field should be displayed in-line with other fields.
    def initialize(name: nil, value: nil, inline: nil)
      @name = name
      @value = value
      @inline = inline
    end

    # @return [Hash] a hash representation of this embed field, to be converted to JSON.
    def to_hash
      {
        name: @name,
        value: @value,
        inline: @inline
      }
    end
  end
end
