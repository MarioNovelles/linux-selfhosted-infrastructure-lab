# Commonly Whitelisted Domains. Exact Pi-hole allowlist
# reference: https://discourse.pi-hole.net/t/commonly-whitelisted-domains/212
#
# Lines starting with # are comments.
# Exact domains and regex rules are kept in separate files.

# Google (Maps, YouTube, etc)
# Google Maps and other Google services

clients4.google.com
clients2.google.com

# Google (Maps, YouTube, etc)
# YouTube history

s.youtube.com
video-stats.l.google.com

# Google (Maps, YouTube, etc)
# YouTube App for iOS

www.googleapis.com
youtubei.googleapis.com
oauthaccountmanager.googleapis.com

# Google (Maps, YouTube, etc)
# Google Play

android.clients.google.com

# Google (Maps, YouTube, etc)
# Google Keep Chrome App sync

reminders-pa.googleapis.com
firestore.googleapis.com

# Google (Maps, YouTube, etc)
# Google Fonts

gstaticadssl.l.google.com

# Google (Maps, YouTube, etc)
# Gmail / Google Mail iOS app connection

googleapis.l.google.com

# Google (Maps, YouTube, etc)
# Google Chrome update on Ubuntu

dl.google.com

# Google (Maps, YouTube, etc)
# Android TV

redirector.gvt1.com

# Google (Maps, YouTube, etc)
# Push notifications for Android apps such as WhatsApp

mtalk.google.com

# Microsoft (Windows, Office, Skype, Xbox, etc)
# Windows connectivity checks

www.msftncsi.com
www.msftconnecttest.com

# Microsoft (Windows, Office, Skype, Xbox, etc)
# Microsoft web pages: Outlook, Office 365, Live, Microsoft.com

outlook.office365.com
products.office.com
c.s-microsoft.com
i.s-microsoft.com
login.live.com
login.microsoftonline.com

# Microsoft (Windows, Office, Skype, Xbox, etc)
# Backup BitLocker recovery key to Microsoft account

g.live.com

# Microsoft (Windows, Office, Skype, Xbox, etc)
# Microsoft Store / Windows Store

dl.delivery.mp.microsoft.com
geo-prod.do.dsp.mp.microsoft.com
displaycatalog.mp.microsoft.com

# Microsoft (Windows, Office, Skype, Xbox, etc)
# Windows 10 Update

sls.update.microsoft.com.akadns.net
fe3.delivery.dsp.mp.microsoft.com.nsatc.net
tlu.dl.delivery.mp.microsoft.com

# Microsoft (Windows, Office, Skype, Xbox, etc)
# Microsoft Edge browser update

msedge.api.cdp.microsoft.com

# Microsoft (Windows, Office, Skype, Xbox, etc)
# Xbox Live sign-ins, new accounts, and account recovery

clientconfig.passport.net

# Microsoft (Windows, Office, Skype, Xbox, etc)
# Xbox Live achievements

v10.events.data.microsoft.com
v20.events.data.microsoft.com

# Microsoft (Windows, Office, Skype, Xbox, etc)
# Xbox Live messaging

client-s.gateway.messenger.live.com

# Microsoft (Windows, Office, Skype, Xbox, etc)
# Store App on Xbox Series X/S

arc.msn.com

# Microsoft (Windows, Office, Skype, Xbox, etc)
# EA Play on Xbox

activity.windows.com

# Microsoft (Windows, Office, Skype, Xbox, etc)
# Xbox Live full functionality

xbox.ipv6.microsoft.com
device.auth.xboxlive.com
title.mgt.xboxlive.com
xsts.auth.xboxlive.com
title.auth.xboxlive.com
ctldl.windowsupdate.com
attestation.xboxlive.com
xboxexperiencesprod.experimentation.xboxlive.com
xflight.xboxlive.com
cert.mgt.xboxlive.com
xkms.xboxlive.com
def-vef.xboxlive.com
notify.xboxlive.com
help.ui.xboxlive.com
licensing.xboxlive.com
eds.xboxlive.com
www.xboxlive.com
v10.vortex-win.data.microsoft.com
settings-win.data.microsoft.com

# Microsoft (Windows, Office, Skype, Xbox, etc)
# Skype

s.gateway.messenger.live.com
ui.skype.com
pricelist.skype.com
apps.skype.com
m.hotmail.com
sa.symcb.com
s1.symcb.com
s2.symcb.com
s3.symcb.com
s4.symcb.com
s5.symcb.com

# Microsoft (Windows, Office, Skype, Xbox, etc)
# Microsoft Office

officeclient.microsoft.com

# Microsoft (Windows, Office, Skype, Xbox, etc)
# Bing Maps Platform

dev.virtualearth.net
ecn.dev.virtualearth.net
t0.ssl.ak.dynamic.tiles.virtualearth.net
t0.ssl.ak.tiles.virtualearth.net

# Apple
# Apple Music

itunes.apple.com
s.mzstatic.com

# Apple
# Apple ID

appleid.apple.com

# Apple
# iOS Weather app

gsp-ssl.ls.apple.com
gsp-ssl.ls-apple.com.akadns.net

# Captive portal tests
# Android / Chrome captive portal detection

connectivitycheck.android.com
clients3.google.com
connectivitycheck.gstatic.com

# Captive portal tests
# Windows / Microsoft captive portal detection

msftncsi.com
ipv6.msftncsi.com

# Captive portal tests
# iOS / Apple captive portal detection

captive.apple.com
gsp1.apple.com
www.apple.com
www.appleiphonecell.com

# Other
# Jackbox.tv

www.google-analytics.com
ssl.google-analytics.com

# Other
# Spotify iOS app and service connection

spclient.wg.spotify.com
apresolve.spotify.com

# Other
# Spotify on TVs

api-tv.spotify.com

# Other
# Target weekly ads

weeklyad.target.com
m.weeklyad.target.com
weeklyad.target.com.edgesuite.net

# Other
# Facebook and Facebook Messenger

upload.facebook.com
creative.ak.fbcdn.net
external-lhr0-1.xx.fbcdn.net
external-lhr1-1.xx.fbcdn.net
external-lhr10-1.xx.fbcdn.net
external-lhr2-1.xx.fbcdn.net
external-lhr3-1.xx.fbcdn.net
external-lhr4-1.xx.fbcdn.net
external-lhr5-1.xx.fbcdn.net
external-lhr6-1.xx.fbcdn.net
external-lhr7-1.xx.fbcdn.net
external-lhr8-1.xx.fbcdn.net
external-lhr9-1.xx.fbcdn.net
fbcdn-creative-a.akamaihd.net
scontent-lhr3-1.xx.fbcdn.net
scontent.xx.fbcdn.net
scontent.fgdl5-1.fna.fbcdn.net
graph.facebook.com
b-graph.facebook.com
connect.facebook.com
cdn.fbsbx.com
api.facebook.com
edge-mqtt.facebook.com
mqtt.c10r.facebook.com
portal.fb.com
star.c10r.facebook.com
star-mini.c10r.facebook.com
b-api.facebook.com
fb.me
bigzipfiles.facebook.com
l.facebook.com
www.facebook.com
scontent-atl3-1.xx.fbcdn.net
static.xx.fbcdn.net
edge-chat.messenger.com
video.xx.fbcdn.net
external-ort2-1.xx.fbcdn.net
scontent-ort2-1.xx.fbcdn.net
edge-chat.facebook.com
scontent-mia3-1.xx.fbcdn.net
web.facebook.com
rupload.facebook.com
l.messenger.com

# Other
# DirecTV

directvnow.com
directvapplications.hb.omtrdc.net
s.zkcdn.net
js.maxmind.com

# Other
# Bild DE

www.asadcdn.com
code.bildstatic.de
de.ioam.de
json.bild.de
script.ioam.de
tags.tiqcdn.com
tagger.opecloud.com

# Other
# Spiegel DE

image.angebote.spiegel.de

# Other
# Plex domains

plex.tv
tvdb2.plex.tv
pubsub.plex.bz
proxy.plex.bz
proxy02.pop.ord.plex.bz
cpms.spop10.ams.plex.bz
meta-db-worker02.pop.ric.plex.bz
meta.plex.bz
tvthemes.plexapp.com.cdn.cloudflare.net
tvthemes.plexapp.com
106c06cd218b007d-b1e8a1331f68446599e96a4b46a050f5.ams.plex.services
meta.plex.tv
cpms35.spop10.ams.plex.bz
proxy.plex.tv
metrics.plex.tv
pubsub.plex.tv
status.plex.tv
www.plex.tv
node.plexapp.com
nine.plugins.plexapp.com
staging.plex.tv
app.plex.tv
o1.email.plex.tv
o2.sg0.plex.tv
dashboard.plex.tv

# Other
# Domains used by Plex: login pictures, metadata, podcasts

gravatar.com
thetvdb.com
themoviedb.com
chtbl.com

# Other
# Sonarr

services.sonarr.tv
skyhook.sonarr.tv
download.sonarr.tv
apt.sonarr.tv
forums.sonarr.tv

# Other
# Placehold.it image placeholders

placehold.it
placeholdit.imgix.net

# Other
# Dropbox

dl.dropboxusercontent.com
ns1.dropbox.com
ns2.dropbox.com

# Other
# Fox News

widget-cdn.rpxnow.com

# Other
# Images on MarketWatch.com

s.marketwatch.com

# Other
# GoDaddy webmail buttons

imagesak.secureserver.net

# Other
# WatchESPN

fpdownload.adobe.com
entitlement.auth.adobe.com
livepassdl.conviva.com

# Other
# NVIDIA GeForce Experience driver updates

gfwsl.geforce.com

# Other
# Videos not playing on times.com and nydailynews.com

delivery.vidible.tv
img.vidible.tv
videos.vidible.tv
edge.api.brightcove.com
cdn.vidible.tv

# Other
# Videos not playing in NCAA March Madness App

live-manifests-aka.warnermediacdn.com

# Other
# Videos not playing on weather.com

v.w-x.co

# Other
# Moto phones OS updates

appspot-preview.l.google.com

# Other
# Grand Theft Auto V Online PC

prod.telemetry.ros.rockstargames.com

# Other
# Chevrolet inventory browsing

chevrolet.com

# Other
# Epic Games Store purchases and 2FA login

tracking.epicgames.com

# Other
# Origin savegame sync

cloudsync-prod.s3.amazonaws.com

# Other
# Red Hat Online Learning embedded video progress

79423.analytics.edgekey.net

# Other
# Lowe's checkout

assets.adobedtm.com

# Other
# Home Depot checkout

nexus.ensighten.com

# Other
# Mozilla Firefox Tracking Protection updates

tracking-protection.cdn.mozilla.net

# Other
# PlayStation 5 Recently Played Games and trophies

telemetry-console.api.playstation.com

# Other
# Canon printer firmware updates

gdlp01.c-wss.com

# Other
# Reddit static assets and uploaded media

styles.redditmedia.com
www.redditstatic.com
reddit.map.fastly.net
www.redditmedia.com
reddit-uploaded-media.s3-accelerate.amazonaws.com

# Other
# Tracking packages sent with DPD

tracking.dpd.de

# Other
# WhatsApp

wa.me
www.wa.me

# Other
# Signal

ud-chat.signal.org
chat.signal.org
storage.signal.org
signal.org
www.signal.org
updates2.signal.org
textsecure-service-whispersystems.org
giphy-proxy-production.whispersystems.org
cdn.signal.org
whispersystems-textsecure-attachments.s3-accelerate.amazonaws.com
d83eunklitikj.cloudfront.net
souqcdn.com
cms.souqcdn.com
api.directory.signal.org
contentproxy.signal.org
turn1.whispersystems.org

# Other
# Twitter / X

twitter.com
upload.twitter.com
api.twitter.com
mobile.twitter.com

# Banks
# TSB Mobile

h-sdk.online-metrix.net
check2.tsb.co.uk

# Banks
# Citizen's Bank

p11.techlab-cdn.com

# Banks
# OLA MONEY

logs.juspay.in

# Restaurants / Rewards
# Burger King

appboy-images.com
rest.iad-03.braze.com

# Restaurants / Rewards
# Punchh: Farmer Boys, El Pollo Loco, Capriotti's, etc.

mobileandroidapi.punchh.com

# Rumble
# Subdomains of rmbl.ws are described in the source as needing wildcard allowlisting.
# The wildcard itself is in the regex allowlist file.


# Dutch / The Netherlands websites
# nu.nl videos and tv guide

cds.s5x3j6q5.hwcdn.net

# Swedish streaming services
# SVT Play resume/continue watching

analytics.svt.se

# Hulu
# Streaming movies or shows

ads-a-darwin.hulustream.com
ads-fa-darwin.hulustream.com
