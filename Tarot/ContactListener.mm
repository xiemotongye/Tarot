//
//  ContactListener.mm
//  Tarot
//
//  Created by huangyimin on 12-12-25.
//
//

#import "ContactListener.h"
#import "SimpleAudioEngine.h"

void ContactListener::BeginContact(b2Contact *contact)
{
    b2Body *bodyA = contact->GetFixtureA()->GetBody();
    b2Body *bodyB = contact->GetFixtureB()->GetBody();
    CCSprite *spriteA = (CCSprite *)bodyA->GetUserData();
    CCSprite *spriteB = (CCSprite *)bodyB->GetUserData();
    
    if (spriteA != NULL && spriteB != NULL) {
        if (arc4random() % 20 == 0) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"se_cardShake.mp3" pitch:1.0 pan:0.0 gain:0.08];
        }
    }
}

void ContactListener::EndContact(b2Contact *contact)
{

}