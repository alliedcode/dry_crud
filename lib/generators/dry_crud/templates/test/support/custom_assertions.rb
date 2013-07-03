# encoding: UTF-8

# A handful of convenient assertions. The aim of custom assertions is to
# provide more specific error messages and to perform complex checks.
#
# Ideally, include this module into your test_helper.rb file:
#  # at the beginning of the file:
#  require 'support/custom_assertions'
#
#  # inside the class definition:
#  include CustomAssertions
module CustomAssertions

  # Asserts that the element is included in the collection.
  def assert_include(collection, element, msg = '')
    full_message = build_message(msg,
                                 "<?> expected to be included in \n<?>.",
                                 element,
                                 collection)
    assert collection.include?(element), full_message
  end

  # Asserts that the element is not included in the collection.
  def assert_not_include(collection, element, msg = '')
    full_message = build_message(msg,
                                 "<?> expected not to be included in \n<?>.",
                                 element,
                                 collection)
    assert !collection.include?(element), full_message
  end

  # Asserts that regexp occurs exactly expected times in string.
  def assert_count(expected, regexp, string, msg = '')
    actual = string.scan(regexp).size
    full_message = build_message(msg,
                                 '<?> expected to occur ? time(s), ' +
                                 "but occured ? time(s) in \n<?>.",
                                 regexp,
                                 expected,
                                 actual,
                                 string)
    assert expected == actual, full_message
  end

  # Asserts that the given active model record is valid.
  # This method used to be part of Rails but was deprecated, no idea why.
  def assert_valid(record, msg = '')
    record.valid?
    full_message = build_message(
        msg,
        "? expected to be valid, but has the following errors: \n ?.",
        record.to_s,
        record.errors.full_messages.join("\n"))
    assert record.valid?, full_message
  end

  # Asserts that the given active model record is not valid.
  # If you provide a set of invalid attribute symbols, all of and only these
  # attributes are expected to have errors. If no invalid attributes are
  # specified, only the invalidity of the record is asserted.
  def assert_not_valid(record, *invalid_attrs)
    msg = build_message('',
                        '? expected to be invalid, but is valid.',
                        record.to_s)
    assert !record.valid?, msg

    if invalid_attrs.present?
      assert_invalid_attrs_have_errors(record, *invalid_attrs)
      assert_other_attrs_have_no_errors(record, *invalid_attrs)
    end
  end

  def build_message(msg, default, *args)
    # TODO: handle minitest format
    message(msg) do
      args.each_with_object(default) do |a, m|
        m.sub!(/\?/, a.to_s)
      end
    end
  end

  # The method used to by Test::Unit to format arguments in
  # #build_message. Prints ActiveRecord objects in a simpler format.
  # Only works for Ruby 1.9
  def mu_pp(obj)
    if obj.is_a?(ActiveRecord::Base) #:nodoc:
      obj.to_s
    else
      super
    end
  end

  private

  def assert_invalid_attrs_have_errors(record, *invalid_attrs)
    invalid_attrs.each do |a|
      msg = build_message('',
                          'Attribute <?> expected to be invalid, ' +
                          'but is valid.',
                          a.to_s)
      assert record.errors[a].present?, msg
    end
  end

  def assert_other_attrs_have_no_errors(record, *invalid_attrs)
    record.errors.each do |a, error|
      msg = build_message('',
                          'Attribute <?> not declared as invalid ' +
                          "attribute, but has the following error: \n?.",
                          a.to_s,
                          error)
      assert invalid_attrs.include?(a), msg
    end
  end

end
