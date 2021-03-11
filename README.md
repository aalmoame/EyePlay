# EyePlay

Instructions for building an running the app:

1. Pull repository on a Mac with XCode installed. 

2. Open the project on XCode through the EyePlay/EyePlay/EyePlay.xcodeproj file.

3. On XCode, Click on the root EyePlay.xcodeproj file in the project navigator. Make sure you are on the "General" interface after clicking.

4. Change the bundle identifier to something unique. By default, it is set to edu.umich.aalmoame.EyePlay (you must change this). Something like [Uniquename].EyePlay should be fine.

5. Navigate to the "Signing & Capabilities" interface. Change the bundle identifier to the bundle identifier you wrote on the "General" interface if it hasn't
been updated already. Additionally, change the team to your personal team. Add an account for a personal team if necessary (using your Apple ID).

6. Connect an iPad Pro (11-inch) (1st Generation) to your Mac. Technically any iPad pro device should work, although this is the specific model we have tested on.

7. Set the active scheme located at the top of XCode to your connected iPad device (it may be set to an iPod Touch simulator by default).

8. Click on the build and run button at the top of XCode (it should look like a 'play' button).
    i. If this is your first time building and running the app, you may encounter an error related to an untrusted developer or something similar.
    ii. To alleviate this, navigate to the settings of your iPad
    iii. Open "General"
    iv. Open "Device Management"
    v. Click on "Apple Development" and approve the app.
    vi. Build and run the app again and it should work.
