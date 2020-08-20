"""
This is a simple Slackbot that will
check a Piazza page for new posts every 1 minute.
Every time a new post is observed a notification will
be sent out
"""

from collections import namedtuple
from datetime import datetime
from time import sleep
import html
import traceback

from piazza_api import Piazza
from slacker import Slacker

# Accessing Piazza and loading data
piazza_id = "" # TODO this is the suffix of the piazza url
piazza_email = "" # TODO your email
piazza_password = "" # TODO your piazza piazza_password
p = Piazza()
p.user_login(email=piazza_email, password=piazza_password)
network = p.network(piazza_id)

# Accessing Slack and configuring the bot
slack_token = "" # TODO Your slack API token goes here
bot=Slacker(slack_token) # authorizing bot
channel = "" # TODO Name of the channel to post to
bot_name = "" # TODO Name of your slackbot

update_interval = 60 # update interval, in seconds

# URL for posts on the page
POST_BASE_URL = "https://piazza.com/class/"+piazza_id+"?cid="

Post = namedtuple("Post", ["nr", "subject", "content_snippet"])

def should_ignore_post(post):
    return "pin" in post or "live" in post

def get_last_id(feed):
    for post in feed:
        if not should_ignore_post(post):
            return post["nr"]
    else:
        return -1

def get_latest_posts(feed, last_id):
    latest_posts = []
    for post in feed:
        is_new_post = post["nr"] > last_id
        if is_new_post and not should_ignore_post(post):
            latest_posts.append(Post(
                nr=post["nr"],
                subject=html.unescape(post["subject"]),
                content_snippet=html.unescape(post["content_snipet"])
            ))
    return latest_posts

def check_for_new_posts(last_id):
    while True:
        try:
            feed = network.get_feed()["feed"]
            latest_posts = get_latest_posts(feed, last_id)
            new_last_id = get_last_id(feed)
            for post in latest_posts:
                message = None
                attachment = [
                    {
                        "fallback": post.subject,
                        "title": post.subject,
                        "title_link": POST_BASE_URL + str(post.nr),
                        "text": post.content_snippet,
                        "color": "good"
                    }
                ]
                bot.chat.post_message(channel,message, \
                    as_user=bot_name,parse="full",attachments=attachment)
            last_id = new_last_id
            sleep(update_interval)
        except:
            traceback.print_exc()
            print("Error when attempting to get Piazza feed, sleeping...")
            sleep(update_interval)

if __name__ == "__main__":
    last_id = get_last_id(network.get_feed()["feed"])
    check_for_new_posts(last_id)
