import {Routes} from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    redirectTo: '/coming-soon',
    pathMatch: 'full'
  },
  {
    path: 'coming-soon',
    loadComponent: () => import('./pages/coming-soon/coming-soon.component').then(c => c.ComingSoonComponent)
  },
];
