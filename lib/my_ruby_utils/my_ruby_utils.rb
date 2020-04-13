# coding: utf-8
module MyRubyUtils

  #
  # Create CUI for choose item from contents_list
  #
  # @param [Array] contents_list Items to choose from.
  # @param [Block] block Block(item, index) Prompt customization.
  # @return [Array] Choosed item and its index.
  #
  def select_contents_from(contents_list, &block)
    # set default content item format if its not given
    block ||= lambda do |value, i|
      sprintf "[%2d] #{value}\n", i
    end

    loop do
      # show choices
      contents_list.each_with_index do |value, i|
        output = block.call(value, i)
        puts output
      end
      print "----------------------------\n"

      # choose one
      print "select contents: "
      input = STDIN.gets.chomp!
      print"\n"

      case input
      when /(^[1-9]+[0-9]*$)|(^0$)/
        index = input.to_i
        return contents_list[index], index if index < contents_list.size
      when "q"
        abort "canceled"
      end

      print "Invalid value !! continue !!!\n\n"
    end
  end


  #
  # Convert second into hour
  #
  # @param [Integer] sec Value to convert.
  # @return [Float] Converted value.
  #
  def sec_to_hour(sec)
    return nil if sec.nil?
    return (sec / 3600.0).round(2)
  end


  #
  # Dump standard output result into the file.
  #
  # @param [String] filename Path to the file.
  # @param [Block] block Sequence done here will dump output.
  #
  def dump_to_file(filename, &block)
    old_stdout = $stdout
    File.open(filename, 'w') do |fo|
      $stdout = fo
      yield
    end
    $stdout = old_stdout
  end
end
