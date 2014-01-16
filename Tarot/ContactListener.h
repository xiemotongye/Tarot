//
//  ContactListener.h
//  Tarot
//
//  Created by huangyimin on 12-12-25.
//
//

#import "Box2D.h"
#import "cocos2d.h"

class ContactListener : public b2ContactListener
{
private:
    void BeginContact(b2Contact* contact);
    void EndContact(b2Contact* contact);
};
