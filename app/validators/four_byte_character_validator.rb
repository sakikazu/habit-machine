class FourByteCharacterValidator < ActiveModel::Validator
  def validate(record)
    string_attributes(record).each do |attribute|
      value = record.read_attribute_for_validation(attribute)
      next if value.blank?
      chars = four_byte_chars(value).uniq
      next if chars.blank?
      record.errors.add(attribute, :invalid_chars, error_chars: chars.join(','))
    end
  end

private

  def string_attributes(record)
    record.class.columns.select { |c| %i(string text).include?(c.type) }.map(&:name)
  end

  def four_byte_chars(string)
    return [] unless string.is_a?(String)
    string.scan(/[\u{10000}-\u{10FFFF}]/)
  end
end
