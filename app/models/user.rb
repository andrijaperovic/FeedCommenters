
class User
  attr_accessor :uid, :graph, :commenters

  def initialize(graph, uid)
    @graph = graph
    @uid = uid
    @commenters = {}
  end

  def likes
    @likes ||= graph.get_connections(uid, 'likes')
  end

  def friends
    @friends ||= graph.get_connections(uid,'friends').sort_by { |hsh| hsh["name"]}
  end

  def friend_feed(id)
    @feed = graph.get_connections(id,"feed?limit=100")
    @page = {}
    while !@page.nil?
      @page = @feed.next_page_params
      begin
        @page.nil? ? break : @feed = graph.get_page(@page)
      rescue Exception => e
        puts "Encountered exception #{e}"
        break
      end
      analyze_feed(@feed,id)
    end
    @commenters.delete(id.to_i)
    @commenters
  end

  def likes_by_category
    @likes_by_category ||= likes.sort_by {|l| l['name']}.group_by {|l| l['category']}.sort
  end

  def analyze_feed(posts,id)
    posts.each do |post|
      if !post["comments"]["count"].nil?
        if (post["comments"]["count"] > 0)
          if (post["from"]["id"].to_i == id.to_i) && post["to"].nil?
            graph.get_connections(post["id"],"comments").each do |comment|
              key = comment["from"]["id"].to_i
              if commenters.has_key?(key)
                commenters[key] = commenters[key] + 1
              else
                commenters[key] = 1
              end
            end
          elsif !post["from"].nil? && !post["to"].nil?
            if !(post["to"]["data"].first).nil?
                if (post["to"]["data"].map(&:values).flatten).include?(id)
                  graph.get_connections(post["id"],"comments").each do |comment|
                    key = comment["from"]["id"].to_i
                    if commenters.has_key?(key)
                      commenters[key] = commenters[key] + 1
                    else
                      commenters[key] = 1
                    end
                  end
                end
            end
          end
        end
      end
    end
  end


end
