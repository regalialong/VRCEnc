![](https://raw.githubusercontent.com/regalialong/VRCEnc/main/VRCEnc_cover.webp)

Scroll to the bottom for combined data / conclusions, [Table on Google Sheets is published here](https://docs.google.com/spreadsheets/d/e/2PACX-1vQxBsc2B5SJczNYwjZ6gLKG1sCrh2aMBE16nlpnVOuRH2jwXpkuBl9nr8-XSOe_x2C_gH6vz74rl22U/pubhtml).

Currently there's little literature about encoding films for VRChat, [the Great Pug has published an article in 2018](https://thegreatpug.com/vrchat-making-a-theater/) about creating a theater which talks about how they encoded their videos. 

This is a fairly old article (while useful) that describes the usage of h264 and aac audio. VRChat themselves meanwhile only [recommends setting faststart](https://web.archive.org/web/20240114211110/https://creators.vrchat.com/worlds/udon/video-players/#optimizing-your-videos) and gives no guidance beyond that.

We are now in 2024 with the world slowly moving away from h264 video and onto better compression formats.

That sparked my interest if this is viable for VRChat in a friend group of mine. 

In this article, I have compiled napkin tests of what combinations of videos work on what platforms in what scenarios in VRChat. While I believe my data is useful in some form, ***you should test this yourself*** to be sure. If your Saw trap fails because you used h265 without precautions, that's not on me.
# tl;dr

I don't know my users and world: mp4(vp9+aac)
~~Windows only, encode speed is critical: mp4(hevc, ac3) (if everyone has extension)~~

AVPro:
Unknown users: webm(vp9+opus)
PC only: webm(av1+opus) (if everyone has extension, free)
Windows only: webm(av1+opus) (if everyone has extension, free)

UPlayer:
Unknown users: mp4(vp9+aac)
PC only: mp4(av1+aac) (if everyone has extension, free)
Windows only: mp4(av1+ac3)

# Primer

Assuming you don't know what any of this means, this section will try to bring you up to speed. You can skip this section you're familiar with video encoding.

Doing video is incredibly expensive in storage terms, you are storing potentially thousands of small images spliced together and audio to accompany it.
In order to cut back on the storage and bandwidth costs, video compression is used to reduce the size of video. Video compression allows trading computing resources (i.e. your CPU or GPU doing work) for smaller file sizes. This is how video streaming services such as YouTube and Netflix are able to exist in the first place (although video still remains very expensive in the grand scheme of things).

![](https://raw.githubusercontent.com/regalialong/VRCEnc/main/VRCEnc_CompressionDemonstration.png)
(Even though we have the same video, one is significantly smaller (35MB vs 84MB, a -58% reduction)! Huzzah!)

Some jargon:
A specific compression algorithm is called a codec.
Running videos through a certain codec is called "encoding", turning that 'encoded' video into something you can watch is called "decoding".
Taking a video in one codec and turning it into another is called "transcoding".

Away from the abstract and heading towards the practical now:
File formats such as `webm` and `mp4` are not actually a specific codec, but they are so-called "container" formats. Their job is to hold the video and audio, as well as subtitles or other data, and describe their contents in a way that video player software can understand.
This is how both video (as in moving pictures) and audio can be combined into a single file, rather than two separate files.
This also allows combining multiple video and audio tracks in DVDs for example.

![](https://raw.githubusercontent.com/regalialong/VRCEnc/main/VRCEnc_MediaInfo.png)
(Tools like MediaInfo can be used to figure out what the contents of a video are. In this case, our smaller file was a webm file containing AV1 with Opus audio.)

The same effectively applies for audio, although audio is cheaper than video.

This way of doing it gives us (usually) a lot of flexibility on how we can combine video and audio, allowing us to mix and match different types of video and audio compression formats.

The focus of this article is specifically on that, which formats work when we mix and match them.

There are two families of video compression we're focusing on, h26* and the webm family.
- h264 is a very widely supported codec and commonly used in mp4, it's widely supported across platforms. It occupies a lingua franca for video because almost all platforms support it.
- h265 is the successor for h264, according to ffmpeg giving 25–50% savings for the same quality compared to h264. It's supported much less however.

The issue about the h26* family is that they are patent-encumbered, needing people wishing to use the tech to pay licensing fees.
For h264, Cisco has released OpenH264 which is open source, where they cover the licensing costs and making it free to use.
The same can't be said for h265 however, which requires paying a licensing pool for usage, which restricts support for it across operating systems.

The webm family in comparison has video codecs which are free to use, allowing them to have greater compatibility across systems:
- VP9 is commonly used in webms and competes with h26*, according to ffmpeg giving 25–50% savings compared to h264.
- AV1 is the successor to VP9, according to ffmpeg giving 30% savings for the same quality compared to VP9. Support is worse but advancing much faster due to its openness.

An advantage that the h26* family has over the webm family is that there is hardware acceleration for encoding, meaning that most consumer GPUs can encode video significantly faster due to dedicated hardware on it than doing it for the CPU.
However, AV1 has been steadily gaining hardware support from the 4090 and from Intel Arc GPUs.
# Testing and data

For these tests, I'll naively use a hierarchy of "best" to "worst" compression formats, generally following compression improvements across every format.
Things at the top are preferred over things at the bottom.

For video:
1. AV1
2. VP9
3. HEVC (i.e h265)
4. AVC (i.e h264)

For audio:
1. Opus
2. AC-3 (also known as Dolby Digital)
3. AAC

Technically, AC3 is worse than AAC in terms of quality, we prefer it hierarchically since it's more commonly used for movies to provide surround sound.
If you don't care for surround, or you don't have an original AC3 track to keep in the file, [Opus generally outperforms AAC](https://listening-test.coresv.net/results.htm).
## Test

Use [`generate_files.sh`](https://github.com/regalialong/VRCEnc/blob/main/generate_files.sh) to transcode a video sample, host it on an HTTP web server (VRChat unfortunately doesn't support `file://` URIs), I did it on MinIO, although nginx should probably do the same. Play back various re-encoded video files in [ProTV Showcase](https://vrchat.com/home/world/wrld_c60b0ea5-f552-44a6-9a88-c89291bcf1bb) and test what works.

Just for the sake of anybody in the future:
All testing done on build 1442, ProTV version by world self reported as 2.3.12.
My system is a NVIDIA GeForce RTX 3080 with a AMD Ryzen 7 5800X3D.

Linux tested on my personal Arch install, running Plasma 6.0.3 with kernel version 6.8.5-arch1-1 and nvidia-550.67-6. Game itself runs per [GE-Proton9-2](https://github.com/GloriousEggroll/proton-ge-custom/releases/tag/GE-Proton9-2)
Windows 10 tested on Pro 22H2 running on a virtual machine with the GPU passed in, with a paravirtualized disk and networking. 
Quest 2 tested on v63.
## Limitations

This test purely goes into what video format combinations play, there are multiple things that aren't considered but are still important practically and worth testing in the future:
- These tests don't actually evaluate if videos benefit from the switch of compression algorithm, just if they play, although they generally should benefit.
- We don't consider the additional overhead from more complex video compression methods.
- We don't test the upper ceiling for VR video quality, such as resolution and bitrate.
	- Since VR is often its own video stream being transmitted to a headset, which has compression on top of the film itself being compressed, I believe there is an upper ceiling for perceivable video quality within VR. This requires separate testing.
- Encode settings are left at ffmpeg's defaults, we don't test the incompatibility of different encode settings.
- This doesn't test how things such as subtitles or fonts included could affect video playback, this requires testing because we experienced some issues with it.
- The Windows 10 test results are done on the Pro version of Windows:
	 - Windows N versions do not ship with what Microsoft describes as the [Media Feature Pack](https://support.microsoft.com/en-us/windows/media-feature-pack-for-windows-10-11-n-february-2023-2aaf89b8-f9d3-4322-98d0-612c9bea9c01), which provides support for Opus and Dolby Digital (ac3) audio, although this can be installed for free on top of N versions.
	 - In my testing, Windows 10 LTSC also does not ship with this and also doesn't have the option to retrofit this.
		 - According to a friend of mine, you may be able to extract and transplant the DLLs from the Media Feature Pack installer, register them and that might fix audio. However this is out of scope, YMMV.
	 - My Windows 11 virtual machine shipped with the HEVC from Device Manufacturer extension (elaborated later), I don't really understand why but W11 might have more media support, YMMV.
## Quest 2 playback

Note that the Quest 2 does not have support for AV1.

| Quest 2 playback (UPlayer) | aac  | opus | ac3   |
| -------------------------- | ---- | ---- | ----- |
| avc (mp4)                  | PASS | PASS | FAILA |
| vp9 (webm)                 | N/A¹ | PASS | N/A¹  |
| av1 (webm)                 | N/A¹ | FAIL | N/A¹  |
| vp9 (mp4)                  | PASS | PASS | FAILA |
| av1 (mp4)                  | FAIL | FAIL | FAIL  |
| hevc (mp4)                 | PASS | PASS | FAILA |

| Quest 2 playback (AVPro) | aac   | opus  | ac3   |
| ------------------------ | ----- | ----- | ----- |
| avc (mp4)                | PASS  | PASS  | FAILA |
| vp9 (webm)               | N/A¹  | PASS  | N/A¹  |
| av1 (webm)               | N/A¹  | FAIL  | N/A¹  |
| vp9 (mp4)                | PASS  | PASS  | FAILA |
| av1 (mp4)                | FAILV | FAILV | FAIL  |
| hevc (mp4)               | PASS  | PASS  | FAILA |

PASS: Working video playback
FAIL: Complete video playback failure
FAILA: Working visual playback but missing audio
FAILV: Working audio playback but missing visuals

¹ webm container format restricts codec inputs
## PC (Windows 10) playback

 VRChat's video players use the Windows Media Foundation as video decode handler on Windows, Windows doesn't ship all by default instead bundles them into "video extensions" on the Microsoft store. The table confirms these are ***required*** to play certain formats through Media Foundation.
Verify that the required extensions are installed on end-user systems using `Get-AppxPackage -Name Microsoft.*VideoExtension`.

| Windows playback (UPlayer) | aac  | opus  | ac3  |
| -------------------------- | ---- | ----- | ---- |
| avc (mp4)                  | PASS | FAILA | PASS |
| vp9 (webm)                 | N/A¹ | FAIL² | N/A¹ |
| vp9 (mp4)                  | PASS | FAILA | PASS |
| av1 (webm, MFE)            | N/A¹ | FAIL² | N/A¹ |
| av1 (mp4, MFE)             | PASS | FAILA | PASS |
| hevc (mp4, MFE)            | PASS | FAILA | PASS |
| **No extensions:**         |      |       |      |
| av1 (webm, NOEXT)          | N/A¹ | FAIL  | N/A¹ |
| av1 (mp4, NOEXT)           | FAIL | FAIL  | FAIL |
| hevc (mp4, NOEXT)          | FAIL | FAIL  | FAIL |

| Windows playback (AVPro) | aac  | opus | ac3  |
| ------------------------ | ---- | ---- | ---- |
| avc (mp4)                | PASS | FAIL | PASS |
| vp9 (webm)               | N/A¹ | PASS | N/A¹ |
| vp9 (mp4)                | PASS | FAIL | PASS |
| av1 (webm, MFE)          | N/A¹ | PASS | N/A¹ |
| av1 (mp4, MFE)           | PASS | FAIL | PASS |
| hevc (mp4, MFE)          | PASS | FAIL | PASS |

PASS: Working video playback
FAIL: Complete video playback failure
FAILA: Working visual playback but missing audio
MFE: Has a corresponding WMF extension installed
NOEXT: Had WMF extension uninstalled for validation, these are always expected to fail

¹ webm container format restricts codec inputs
² This failure is likely related due to broken webm handling by UPlayer.
## PC (Linux) playback

This is expected to have fewer options for playback due to missing video decoding infrastructure for the patent encumbered formats.

| Linux playback (UPlayer) | aac  | opus  | ac3   |
| ------------------------ | ---- | ----- | ----- |
| avc (mp4)                | PASS | PASS  | FAILA |
| vp9 (webm)               | N/A¹ | FAIL² | N/A¹  |
| av1 (webm)               | N/A¹ | FAIL² | N/A¹  |
| av1 (mp4)                | PASS | PASS  | FAILA |
| vp9 (mp4)                | PASS | PASS  | FAILA |
| hevc (mp4)               | FAIL | FAIL  | FAIL  |

| Linux playback (AVPro) | aac   | opus  | ac3   |
| ---------------------- | ----- | ----- | ----- |
| avc (mp4)              | PASS  | PASS  | FAILA |
| vp9 (webm)             | N/A¹  | PASS  | N/A¹  |
| av1 (webm)             | N/A¹  | PASS  | N/A¹  |
| av1 (mp4)              | PASS  | PASS  | FAILA |
| vp9 (mp4)              | PASS  | PASS  | FAILA |
| hevc (mp4)             | FAILV | FAILV | FAIL  |

PASS: Working video playback
FAIL: Complete video playback failure
FAILA: Working visual playback but missing audio

¹ webm container format restricts codec inputs
² This failure is likely related due to broken webm handling by UPlayer.
# Combined table and conclusions

You may prefer to [view this over Google Sheets](https://docs.google.com/spreadsheets/d/e/2PACX-1vQxBsc2B5SJczNYwjZ6gLKG1sCrh2aMBE16nlpnVOuRH2jwXpkuBl9nr8-XSOe_x2C_gH6vz74rl22U/pubhtml) which has coloring.

| Combined table    | W10 (U) | Linux (U) | Q2 (U) |     | W10 (A) | Linux (A) | Q2 (A) |
| ----------------- | ------- | --------- | ------ | --- | ------- | --------- | ------ |
| av1, opus \[webm] | FAIL    | FAIL      | FAIL   |     | PASS    | PASS      | FAIL   |
| av1, aac \[mp4]   | PASS    | PASS      | FAIL   |     | PASS    | PASS      | FAILV  |
| av1, opus \[mp4]  | FAILA   | PASS      | FAIL   |     | FAIL    | PASS      | FAILV  |
| av1, ac3 \[mp4]   | PASS    | FAILA     | FAIL   |     | PASS    | FAILA     | FAIL   |
| vp9, opus \[webm] | FAIL    | FAIL      | PASS   |     | PASS    | PASS      | PASS   |
| vp9, aac \[mp4]   | PASS    | PASS      | PASS   |     | PASS    | PASS      | PASS   |
| vp9, opus \[mp4]  | FAILA   | PASS      | PASS   |     | FAIL    | PASS      | PASS   |
| vp9, ac3 \[mp4]   | PASS    | FAILA     | FAILA  |     | PASS    | FAILA     | FAILA  |
| hevc, aac \[mp4]  | PASS    | FAIL      | PASS   |     | PASS    | FAILV     | PASS   |
| hevc, opus \[mp4] | FAILA   | FAIL      | PASS   |     | FAIL    | FAILV     | PASS   |
| hevc, ac3 \[mp4]  | PASS    | FAIL      | FAILA  |     | PASS    | FAIL      | FAILA  |
| avc, aac \[mp4]   | PASS    | PASS      | PASS   |     | PASS    | PASS      | PASS   |
| avc, opus \[mp4]  | FAILA   | PASS      | PASS   |     | FAIL    | PASS      | PASS   |
| avc, ac3 \[mp4]   | PASS    | FAILA     | FAILA  |     | PASS    | FAILA     | FAILA  |

U=Unity Player, A=AVPro
PASS: Working playback
FAILA: Missing audio
FAILV: Missing video
FAIL: Complete playback failure
This table implies the system has the video extensions for Windows.

There are some quirks we can draw out of this:
- Q2 never supports AV1 or AC3 audio
- W10 as of writing fails to use opus for non-webm formats
- PC Unity Player fails to parse VP9/AV1 webms, [because Unity forgot to implement it.](https://forum.unity.com/threads/5-years-ago-webm-vp9-support-was-promised-now-nothing-any-probability-of-follow-through.1231605)
	- In my opinion this is a bug, it might be worth a canny ticket.
- AVPro is able to handle webm correctly
- AVPro manages to FAILV where UPlayer would FAIL
## Baselines

Assuming the data is 100% absolute and correct (it probably isn't), depending on which player, multiple baselines can be drawn:
### Player independent

No matter what player, mp4(vp9+aac) works across players on every operating system. The VP9 video extension is preinstalled for Windows 10 consumer builds, avoiding Video Extension hell.
A problem with VP9 is its slow encoding speed. There is plenty of literature online on how to increase the encoding speed for VP9 however due to its use in the VOD sector.

There is also SVT-VP9 [here](https://github.com/OpenVisualCloud/SVT-VP9) by the same team that sped up the encode for AV1, this one is not included by default in ffmpeg however. It can be compiled as a ffmpeg plugin [as described here](https://github.com/OpenVisualCloud/SVT-VP9/blob/master/ffmpeg_plugin/README.md). I haven't tested or used this so YMMV.

> `libvpx-vp9` can save about 20–50% bitrate compared to `libx264` (the default [H.264](https://trac.ffmpeg.org/wiki/Encode/H.264) encoder), while retaining the same visual quality.

If there's only Windows players, mp4(av1+ac3) is better but AV1 requires a video extension, see AVPro section.
#### What about AVC?

AVC is also a universally supported option from our table but the compression is worse compared to VP9, so it doesn't make sense to use it unless you need encoding speed (since h264 can be hardware accelerated unlike VP9).
### AVPro

webm(vp9+opus) is the best generalist baseline for AVPro. mp4 is not an option due the W10 non-webm opus bug mentioned above. 

For PC only, webm(av1+opus) is the _technically_ correct best combination.
The _technically_ part kicks in because W10 users need the [AV1 Video Extension](https://apps.microsoft.com/detail/9mvzqvxjbq9v?hl=en-us&gl=US) on their systems before AV1 video works, meaning every viewer has to make sure they have this installed.
If everyone installs it from the Microsoft store for free, this is probably the best option all around. 

AV1 similar to VP9 had a history of bad encode speeds however SVT-AV1 is a multithreaded CPU encoder that has been fairly competitive with the other formats from what I was able to tell, [it's included in ffmpeg](https://trac.ffmpeg.org/wiki/Encode/AV1#SVT-AV1) as `libsvtav1`.
> Depending on the use case, AV1 can achieve about 30% higher compression efficiency than VP9, and about 50% higher efficiency than H.264.

For Windows only, assuming encode speed is critical, mp4(hevc, ac3) is inferior to AV1 but an option with hardware encoding.
The problem is W10 users need the wordy [HEVC Video Extensions from Device Manufacturer](https://apps.microsoft.com/detail/9n4wgh0z6vhq?) on their systems before HEVC video works, meaning every viewer has to make sure they have this installed.
Unlike AV1, the issue is that the HEVC Video Extension is paid. Some systems may have this preinstalled already from their GPU, YMMV. There used to be an exploit that allowed you to get it from the store for free, this has been fixed and therefore now requires the video extension to be sideloaded or paid for.
### Unity Player

UPlayer has two bugs working against it:
- W10 fails to load opus audio for non-webm formats (i.e mp4)
- UPlayer fails to load webm outright, even though they contain native formats (VP9,AV1)
This makes our choices tighter.

mp4(vp9+aac) is the best generalist choice for UPlayer. VP9 speed concerns from above apply.
For PC only, mp4(av1+aac) is the best option. AV1 extension concerns above apply.
For Windows only, mp4(av1+ac3) is the best option. AV1 extension concerns above apply.
