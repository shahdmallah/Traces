import { Router } from 'express'
import { authenticate } from '../../shared/middleware/auth.middleware'
import * as controller from './social.controller'

export const socialRouter = Router()

socialRouter.post('/users/:id/follow', authenticate, controller.follow)
socialRouter.delete('/users/:id/follow', authenticate, controller.unfollow)
socialRouter.get('/users/:id/followers', controller.followers)
socialRouter.get('/users/:id/following', controller.following)
socialRouter.post('/activities/:id/like', authenticate, controller.like)
socialRouter.delete('/activities/:id/like', authenticate, controller.unlike)
socialRouter.post('/activities/:id/comments', authenticate, controller.comment)
socialRouter.delete('/comments/:id', authenticate, controller.removeComment)
socialRouter.get('/activities/:id/comments', controller.comments)
socialRouter.get('/feed', authenticate, controller.feed)
