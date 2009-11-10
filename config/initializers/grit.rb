
class Grit::Repo
def commits_between_dates(from,to)
  Grit::Commit.find_all(self,nil,:since => from.to_s, :until => to.to_s)
end

end
