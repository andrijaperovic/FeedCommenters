require 'spec_helper'

describe User do
  before do
    @graph = mock('api')
    @uid = 42
    @user = User.new(@graph, @uid)
  end

  describe 'retrieving friends' do
    before do
      @friends = [
        {
          "name" => "John Smith",
          "id" => "1"
        },
        {
          "name" => "Mike Peters",
          "id" => "2"
        },
        {
          "name" => "George Clooney",
          "id" => "3"
        },
        {
          "name" => "Time Warner",
          "id" => "4"
        }
      ]
      @graph.should_receive(:get_connections).with(@uid, 'friends').once.and_return(@friends)
    end

    describe '#friends' do
      it 'should retrieve the friends of the user via the graph api' do
        @user.friends.should == @friends.sort_by { |hsh| hsh["name"]}
      end

      it 'should memorize the result after the first call' do
        friends1 = @user.friends
        friends2 = @user.friends
        friends2.should equal(friends1)
      end
    end

  end

  describe "analyzing the feed" do

    before do
      @posts = [{
        "id"=> "720855584_10150907263340585",
        "from"=> {
          "name"=> "Catherine Nguyen",
          "id"=> "506157135"
        },
        "to"=> {
          "data"=> [{
            "name"=> "Ross Hale",
            "id"=> "720855584"
          }]
        },
        "message"=> "yay!  so excited.  tons of bisous and hugs!",
        "actions"=> [{
          "name"=> "Comment",
          "link"=> "http://www.facebook.com/720855584/posts/10150907263340585"
        }, {
          "name"=>"Like",
          "link"=>"http://www.facebook.com/720855584/posts/10150907263340585"
        }],
        "type"=>"status",
        "created_time"=>"2011-10-25T00:46:26+0000",
        "updated_time"=>"2011-10-25T00:46:26+0000",
        "comments"=>{
          "count"=>0
        }
      }, {
        "id"=>"720855584_10150898010125585",
        "from"=>{
          "name"=>"Ross Hale",
          "id"=>"720855584"
        },
        "story"=>"\"Whoa, movin on up!...\" on Housewarming Party's Wall.",
        "story_tags"=>{
          "27"=>[{
            "id"=>241968702519271,
            "name"=>"Housewarming Party",
            "offset"=>27,
            "length"=>18
          }]
        },
        "type"=>"status",
        "created_time"=>"2011-10-20T22:22:48+0000",
        "updated_time"=>"2011-10-20T22:22:48+0000",
        "comments"=>{
          "count"=>0
        }
      }, {
        "id"=>"720855584_10150882410335585",
        "from"=>{
          "name"=>"Elyse Hale Lake",
          "id"=>"3611693"
        },
        "to"=>{
          "data"=>[{
            "name"=>"Ross Hale",
            "id"=>"720855584"
          }]
        },
        "message"=>"ROSSY!!! I miss you!  What are you up to these days?  Are you guys going to be in SB over the holidays?",
        "actions"=>[{
          "name"=>"Comment",
          "link"=>"http://www.facebook.com/720855584/posts/10150882410335585"
        }, {
          "name"=>"Like",
          "link"=>"http://www.facebook.com/720855584/posts/10150882410335585"
        }],
        "type"=>"status",
        "created_time"=>"2011-10-13T14:36:38+0000",
        "updated_time"=>"2011-10-13T21:05:37+0000",
        "comments"=>{
          "data"=>[{
            "id"=>"720855584_10150882410335585_26619262",
            "from"=>{
              "name"=>"Richard H. Lake",
              "id"=>"1205908706"
            },
            "message"=>"Fight nice you two. How about us here on the other side of the world.",
            "created_time"=>"2011-10-13T19:19:18+0000"
          }, {
            "id"=>"720855584_10150882410335585_26622643",
            "from"=>{
              "name"=>"Elyse Hale Lake",
              "id"=>"3611693"
            },
            "message"=>"Mom and Dad visit all the time.  You're right Rick!  Erik and I are checking flights for the holiday season!  I would love to see everyone, and some changing leaves would be cool too.",
            "created_time"=>"2011-10-13T21:05:37+0000"
          }],
          "count"=>5
        }}]

      @comments = [{
        "id"=>"720855584_10150882410335585_26616763",
        "from"=>{
          "name"=>"Ross Hale",
          "id"=>"720855584"
        },
        "message"=>"Hello Sister!  I miss you too, you never visit!  I still have a wedding present for you.  Hint: It's 9'6\" and about 30\" wide with a rounded pin tail :)",
        "created_time"=>"2011-10-13T18:00:53+0000"
      }, {
        "id"=>"720855584_10150882410335585_26617001",
        "from"=>{
          "name"=>"Elyse Hale Lake",
          "id"=>"3611693"
        },
        "message"=>"Nice!  We need to get up there. But you have never visited!  I want to show you our sweet place!",
        "created_time"=>"2011-10-13T18:08:09+0000"
      }, {
        "id"=>"720855584_10150882410335585_26617263",
        "from"=>{
          "name"=>"Ross Hale",
          "id"=>"720855584"
        },
        "message"=>"This is true, also M\u00e9m\u00e9 really wants me to come down and fix her computer... BUT don't you wanna see mom and dad too?",
        "created_time"=>"2011-10-13T18:16:09+0000"
      }, {
        "id"=>"720855584_10150882410335585_26619262",
        "from"=>{
          "name"=>"Richard H. Lake",
          "id"=>"1205908706"
        },
        "message"=>"Fight nice you two. How about us here on the other side of the world.",
        "created_time"=>"2011-10-13T19:19:18+0000"
      }, {
        "id"=>"720855584_10150882410335585_26622643",
        "from"=>{
          "name"=>"Elyse Hale Lake",
          "id"=>"3611693"
        },
        "message"=>"Mom and Dad visit all the time.  You're right Rick!  Erik and I are checking flights for the holiday season!  I would love to see everyone, and some changing leaves would be cool too.",
        "created_time"=>"2011-10-13T21:05:37+0000"
      }]

        @graph.should_receive(:get_connections).with("720855584_10150882410335585", 'comments').once.and_return(@comments)
    end

    describe "#analyze_feed" do

      it 'should retrieve a hash with ranked commenters on the user\'s profile' do
        @user.analyze_feed(@posts,"720855584")
        @user.commenters == {720855584=>2, 3611693=>2, 1205908706=>1}
      end
      
    end
  end
end
