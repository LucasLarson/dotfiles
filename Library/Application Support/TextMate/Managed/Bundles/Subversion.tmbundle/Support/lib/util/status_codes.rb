module Subversion
  class StatusCodes
    
    @@status_code_mapping = {
      "none" => "",
      "normal" => "",
      "modified" => "M",
      "merged" => "G",
      "added" => "A",
      "updated" => "U",
      "deleted" => "D",
      "conflicted" => "C",
      "unversioned" => "?",
      "external" => "X",
      "ignored" => "I",
      "incomplete" => "!",
      "missing" => "!",
      "obstructed" => '~',
      "replaced" => 'R',
      "unversioned" => '?'
    }
    
    def self.copied
      "+"
    end
    
    def self.wc_locked
      "L"
    end
    
    def self.switched
      "S"
    end
    
    def self.locked
      "K"
    end
    
    def self.status(code)
      @@status_code_mapping.index(code)
    end
    
    def self.code(status)
      @@status_code_mapping[status]
    end
    
  end
end
