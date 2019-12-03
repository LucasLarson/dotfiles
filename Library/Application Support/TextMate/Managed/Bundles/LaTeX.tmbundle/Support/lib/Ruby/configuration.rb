# -- Imports -------------------------------------------------------------------

require ENV['TM_SUPPORT_PATH'] + '/lib/osx/plist'

# -- Class ---------------------------------------------------------------------

# Extend the array class so we can easily check all types contained in a list.
class Array
  def all_of_type?(type)
    entries.all? { |entry| entry.is_a?(type) }
  end
end

# -- Module --------------------------------------------------------------------

# This class provides access to the LaTeX configuration files.
module Configuration
  class <<self
    def load
      merge_plists(load_default_file, load_user_file)
    end

    private

    def load_file(filename)
      return nil unless FileTest.exist?(filename)

      File.open(filename) do |f|
        plist = OSX::PropertyList.load(f)
        return plist
      end
    end

    def load_user_file
      user_file = File.expand_path(
        '~/Library/Preferences/com.macromates.textmate.latex_config.plist'
      )
      load_file(user_file)
    end

    def load_default_file
      default_file = ENV['TM_BUNDLE_SUPPORT'] + '/config/latex.config'
      load_file(default_file)
    end

    # Merges the two data structures read from plists. The structures should
    # consist of hashes, arrays and strings only. The users list takes
    # precedence in case of ties.
    def merge_plists(default_list, user_list)
      return user_list unless default_list

      return default_list unless user_list

      merge_defined_plists(default_list, user_list)
    end

    def merge_defined_plists(default_list, user_list)
      lists = [default_list, user_list]
      return merge_hashes(default_list, user_list) if lists.all_of_type?(Hash)
      return (user_list + default_list).uniq if lists.all_of_type?(Array)
      return user_list if lists.all_of_type?(String)

      raise MismatchedTypesException,
            "Found mismatched types: #{default_list} is a " \
            "#{default_list.class} while #{user_list} is a #{user_list.class}."
    end

    def merge_hashes(default_list, user_list)
      new_hash = {}
      (user_list.keys + default_list.keys).uniq.each do |key|
        new_hash[key] = merge_plists(default_list[key], user_list[key])
      end
      new_hash
    end
  end
end
