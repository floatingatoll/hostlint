###############################################################################
# rubyfixes
###############################################################################

# metaprogramming ruby trick; builtin in 1.9
class Symbol
  def to_proc
    Proc.new { |x| x.send(self) }
  end
end

###############################################################################
