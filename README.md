# RVAppStoreVersionChecker
To update latest version of this App


Installation :- 

pod 'RVAppStoreVersionChecker', '~> 1.1'


How to Use :- 

import RVAppStoreVersionChecker

Get status and Default Popup :- 

RVAppStoreVersionChecker.instance.showMessageIfUpdateAvailable(message: "", updateBtnMessage: "", reminderBtnMessage: "") { (hasUpdate, response) in
            debugPrint("Has update :", hasUpdate)
        }
